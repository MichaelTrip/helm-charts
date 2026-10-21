"""Render regression tests for Argo CD Secret drift (no cluster required)."""

import base64
from pathlib import Path
import subprocess
import unittest


CHART = Path(__file__).resolve().parents[1]


def render(**values):
    command = ["helm", "template", "journiv", str(CHART), "--namespace", "journiv"]
    for key, value in values.items():
        command.extend(["--set-string", f"{key}={value}"])
    return subprocess.run(command, capture_output=True, text=True)


class SecretRenderingTests(unittest.TestCase):
    credentials = {
        "config.secretKey": 'app-key-with-"quotes":and-symbols!',
        "postgresql.auth.password": "db-password-with-symbols!",
    }

    def successful_render(self, values):
        result = render(**values)
        self.assertEqual(result.returncode, 0, result.stderr)
        return result.stdout

    def assert_encoded(self, output, key, value):
        encoded = base64.b64encode(value.encode()).decode()
        self.assertIn(f'  {key}: "{encoded}"', output)

    def test_repeated_renders_are_identical(self):
        first = self.successful_render(self.credentials)
        second = self.successful_render(self.credentials)
        self.assertEqual(first, second)
        self.assertNotIn("stringData:", first)
        self.assert_encoded(first, "SECRET_KEY", self.credentials["config.secretKey"])
        self.assert_encoded(
            first, "POSTGRES_PASSWORD", self.credentials["postgresql.auth.password"]
        )

    def test_missing_app_key_fails_with_actionable_error(self):
        result = render(**{"postgresql.auth.password": "db-password"})
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Set config.secretKey or config.existingSecret", result.stderr)

    def test_missing_database_password_fails_with_actionable_error(self):
        result = render(**{"config.secretKey": "app-key"})
        self.assertNotEqual(result.returncode, 0)
        self.assertIn(
            "Set postgresql.auth.password or config.postgres.existingSecret",
            result.stderr,
        )

    def test_existing_secrets_need_no_inline_credentials(self):
        values = {
            "config.existingSecret": "external-app",
            "config.postgres.existingSecret": "external-db",
        }
        output = self.successful_render(values)
        self.assertEqual(output, self.successful_render(values))
        self.assertNotIn("kind: Secret\n", output)
        self.assertIn("name: external-app\n                  key: SECRET_KEY", output)
        # Both the application and bundled database must use the external Secret.
        self.assertEqual(
            output.count("name: external-db\n                  key: POSTGRES_PASSWORD"),
            2,
        )

    def test_existing_app_secret_with_managed_database_secret(self):
        output = self.successful_render({
            "config.existingSecret": "external-app",
            "postgresql.auth.password": "db-password",
        })
        self.assertEqual(output.count("kind: Secret\n"), 1)
        self.assert_encoded(output, "POSTGRES_PASSWORD", "db-password")

    def test_existing_database_secret_with_managed_app_secret(self):
        output = self.successful_render({
            "config.secretKey": "app-key",
            "config.postgres.existingSecret": "external-db",
        })
        self.assertEqual(output.count("kind: Secret\n"), 1)
        self.assert_encoded(output, "SECRET_KEY", "app-key")

    def test_connection_string_is_encoded_with_custom_key(self):
        url = "postgresql://user:password@database:5432/journiv"
        output = self.successful_render({
            **self.credentials,
            "config.postgres.connectionString": url,
            "config.postgres.connectionStringSecretKey": "CUSTOM_URL",
        })
        self.assert_encoded(output, "CUSTOM_URL", url)
        self.assertNotIn(url, output)


if __name__ == "__main__":
    unittest.main()
