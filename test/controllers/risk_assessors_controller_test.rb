require "test_helper"

class RiskAssessorsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get risk_assessors_new_url
    assert_response :success
  end

  test "should get create" do
    get risk_assessors_create_url
    assert_response :success
  end
end
