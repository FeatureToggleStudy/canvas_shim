describe SettingsService::Commands::UpdateSettings do
  before do
    SettingsService.canvas_domain = 'somedomain.com'
  end
  subject do
    described_class.new(
      id: 1,
      setting: 'foo',
      value: 'bar',
      object: 'assignment'
    )
  end

  describe '#call' do
    it 'saves the setting to the repository' do
      allow(SettingsService::Repository).to receive(:create_table)
      expect(SettingsService::Repository).to receive(:put).with(
        :table_name=>"somedomain.com-assignment_settings",
        :id=>1,
        :setting=>"foo",
        :value=>"bar"
      )
      subject.call
    end
  end
end
