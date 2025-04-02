run "setup_tests" {
    module{
        source = "./tests/setup"
    }    
}

run "create_bucket" {
    command = plan
   
    assert {
      condition = output.repository_url == "${run.setup_tests.bucket_prefix}-aws-s3-website-test"
      error_message = "invalid bucket name"
    }
}