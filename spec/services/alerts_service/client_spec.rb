describe AlertsService::Client do
  subject { described_class }

  let(:alert) { double('alert') }
  let(:http_client) { double('http_client', post: nil) }
  
  before do
    allow(subject.instance).to receive('school_name').and_return('myschool')
  end

  describe '#show' do
    it do
      VCR.use_cassette 'alerts_service/client/show' do
        expect(subject.show(1)).to eq 200
      end  
    end
  end

  describe '#list' do
    it do
      VCR.use_cassette 'alerts_service/client/list' do
        expect(subject.list(alert)).to eq 200
      end  
    end
  end

  describe '#create' do
    it do
      VCR.use_cassette 'alerts_service/client/create' do
        expect(subject.create(alert)).to eq 200
      end
    end
  end

  describe '#destroy' do
    it do
      VCR.use_cassette 'alerts_service/client/destroy' do
        expect(subject.destroy(1)).to eq 200
      end
    end
  end
end