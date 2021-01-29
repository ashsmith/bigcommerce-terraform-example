
# Create a zip containing our code...
data "archive_file" "code" {
  type        = "zip"
  source_file = "${path.module}/code/index.js"
  output_path = "${path.module}/code/function-code.zip"
}

# Create a GCS bucket.
resource "google_storage_bucket" "bucket" {
  name = "ashs-test-29012020"
}

# Upload an object to our bucket.
resource "google_storage_bucket_object" "archive" {
  name   = "function-code.zip"
  bucket = google_storage_bucket.bucket.name
  source = "${path.module}/code/function-code.zip"
}

resource "google_cloudfunctions_function" "function" {
  name        = "my-super-function"
  description = "My function"
  runtime     = "nodejs12"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  trigger_http          = true
  entry_point           = "testing"
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

resource "bigcommerce_webhook" "customer_webhook" {
  scope = "store/customer/*"
  destination = google_cloudfunctions_function.function.https_trigger_url
  is_active = true
}