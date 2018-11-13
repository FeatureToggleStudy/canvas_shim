describe UnitsService::Commands::GetUnitGrades do
  let(:course) { double('course') }
  let(:user) { double('user') }
  let(:content_tag) { double('content_tag') }
  let(:context_module1) { double('context_module', id: 1) }
  let(:context_module2) { double('context_module', id: 2) }
  let(:submission1) { double('submission', score: 100) }
  let(:submission2) { double('submission', score: 50) }

  let(:query_results) do
    result = {}
    result[context_module1] = [submission1, submission2]
    result[context_module2] = [submission1, submission2]
    result
  end

  let(:query_instance) { double('query instance', query: query_results) }
  subject { described_class.new(course: course, student: user) }

  before do
    allow(UnitsService::Queries::GetSubmissions).to receive(:new).and_return(query_instance)
  end

  it 'returns the unit grade' do
    expectation = {}
    expectation[context_module1.id] = 75
    expectation[context_module2.id] = 75
    expect(subject.call).to eq(expectation)
  end
end