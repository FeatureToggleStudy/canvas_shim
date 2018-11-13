describe UnitsService::Queries::GetItems do
  let(:course) { Course.create(context_modules: [context_module]) }
  let(:context_module) { ContextModule.create(content_tags: [content_tag]) }
  let(:content_tag) { ContentTag.create(content: assignment) }
  let(:assignment) { Assignment.create }
  let(:submission) { Submission.create(assignment: assgnment) }

  subject { described_class.new(course: course) }

  context 'tags with content' do
    let(:content_tag) { ContentTag.create(content: assignment) }

    it 'returns a content tag' do
      result = {}
      result[context_module] = [content_tag]
      expect(subject.query).to eq(result)
    end
  end

  context 'tags without content' do
    let(:content_tag) { ContentTag.create(content: nil) }
    it 'does not return a content tag' do
      result = {}
      result[context_module] = []
      expect(subject.query).to eq(result)
    end
  end

  context 'content without submission' do
    let(:unsubmittable_content) { Course.create }
    let(:content_tag) { ContentTag.create(content: unsubmittable_content) }
    it 'does not return a content tag' do
      result = {}
      result[context_module] = []
      expect(subject.query).to eq(result)
    end
  end
end