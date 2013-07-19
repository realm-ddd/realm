require 'spec_helper'

require 'realm/core_ext/object/required'

describe Object do
  let(:klass) {
    Class.new(Object) do
      def method_with_keyword_arg(keyword_arg: required(:keyword_arg))
        keyword_arg
      end
    end
  }

  subject(:object) {
    klass.new
  }

  describe "#required" do
    example "with a required keyword arg" do
      expect(object.method_with_keyword_arg(keyword_arg: :arg)).to be == :arg
    end

    example "without required keyword arg" do
      expect {
        object.method_with_keyword_arg
      }.to raise_error(
        ArgumentError, "Required keyword argument missing: :keyword_arg"
      )
    end
  end
end