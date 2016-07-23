# encoding: utf-8

describe RuboCop::Cop::RSpec::VerifiedDoubles, :config do
  subject(:cop) { described_class.new(config) }

  it 'finds a `double` instead of an `instance_double`' do
    inspect_source(cop, ['it do',
                         '  foo = double("Widget")',
                         'end'])
    expect(cop.messages)
      .to eq(['Prefer using verifying doubles over normal doubles.'])
    expect(cop.highlights).to eq(['double("Widget")'])
    expect(cop.offenses.map(&:line).sort).to eq([2])
    expect(cop.offenses.map(&:to_s).sort).to all(
      eql('C:  2:  9: Prefer using verifying doubles over normal doubles.')
    )
  end

  context 'when configuration does not specify IgnoreSymbolicNames' do
    let(:cop_config) { Hash.new }

    it 'find doubles whose name is a symbol' do
      inspect_source(cop, ['it do',
                           '  foo = double(:widget)',
                           'end'])
      expect(cop.messages)
        .to eq(['Prefer using verifying doubles over normal doubles.'])
      expect(cop.highlights).to eq(['double(:widget)'])
      expect(cop.offenses.map(&:line).sort).to eq([2])
    end

    it 'finds a `spy` instead of an `instance_spy`' do
      inspect_source(cop, ['it do',
                           '  foo = spy("Widget")',
                           'end'])
      expect(cop.messages)
        .to eq(['Prefer using verifying doubles over normal doubles.'])
      expect(cop.highlights).to eq(['spy("Widget")'])
      expect(cop.offenses.map(&:line).sort).to eq([2])
    end
  end

  context 'when configured to ignore symbolic names' do
    let(:cop_config) { { 'IgnoreSymbolicNames' => true } }

    it 'ignores doubles whose name is a symbol' do
      inspect_source(cop, ['it do',
                           '  foo = double(:widget)',
                           'end'])
      expect(cop.messages).to be_empty
    end

    it 'still flags doubles whose name is a string' do
      inspect_source(cop, ['it do',
                           '  foo = double("widget")',
                           'end'])

      expect(cop.messages.first).to eq(
        'Prefer using verifying doubles over normal doubles.'
      )
    end
  end

  it 'ignores doubles without a name' do
    inspect_source(cop, ['it do',
                         '  foo = double',
                         'end'])
    expect(cop.messages).to be_empty
  end

  it 'ignores instance_doubles' do
    inspect_source(cop, ['it do',
                         '  foo = instance_double("Foo")',
                         'end'])
    expect(cop.messages).to be_empty
  end
end
