# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::RSpecDescribeMethod do
  subject(:cop) { described_class.new }

  it 'enforces non-method names' do
    inspect_source(cop, ["describe Some::Class, 'nope' do; end"])
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.map(&:line).sort).to eq([1])
    expect(cop.messages)
    .to eq(['The second argument to describe should be the method being ' \
            "tested. '#instance' or '.class'"])
  end

  it 'skips methods starting with a . or #' do
    inspect_source(cop, ["describe Some::Class, '.asdf' do; end",
                         "describe Some::Class, '#fdsa' do; end"])
    expect(cop.offenses).to be_empty
  end
end
