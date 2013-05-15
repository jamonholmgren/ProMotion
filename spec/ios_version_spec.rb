describe "ios version" do

  before do
    @dummy = DummyClass.new
    @dummy.extend ProMotion::SystemHelper
  end

  it "#ios_version_is?" do
    @dummy.ios_version_is?(@dummy.ios_version).should.be.true
  end

  it "#ios_version_greater?" do
    @dummy.ios_version_greater?('1.0').should.be.true
  end

  it "#ios_version_greater_eq?" do
    @dummy.ios_version_greater_eq?(@dummy.ios_version).should.be.true
  end

  it "#ios_version_less?" do
    @dummy.ios_version_less?('9.0').should.be.true
  end

  it "#ios_version_less_eq?" do
    @dummy.ios_version_less_eq?(@dummy.ios_version).should.be.true
  end

end
