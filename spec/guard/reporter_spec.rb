require 'spec_helper'
require 'guard/reporter'

describe Guard::Reporter do
  subject {Guard::Reporter.new}
  
  it "respond_to failure" do
    subject.should respond_to :failure
  end
  it "respond_to success" do
    subject.should respond_to :success
  end
  it "respond_to announce" do
    subject.should respond_to :announce
  end
  it "respond_to unstable" do
    subject.should respond_to :unstable
  end
end