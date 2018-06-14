describe SettingsService::Commands::GetSettings do
  before do
    SettingsService.canvas_domain = 'somedomain.com'
  end

  subject do
    SettingsService::Commands::GetSettings.new(
      id: 1,
      object: 'assignment'
    )
  end

  describe '#call' do
    it 'gets the settings from the repository' do
      allow(SettingsService::Repository).to receive(:create_table)
      expect(SettingsService::Repository).to receive(:get).with(
        :table_name=>"somedomain.com-assignment_settings",
        :id=>1
      )
      subject.call
    end
  end
end
