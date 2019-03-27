describe User do
  let(:subject) { User.create }
  let(:enrollment) { double('enrollment') }
  let(:enrollments) { double('enrollments', where: [enrollment])}
  let(:response) { double('response', body: [discussion_topic.id].to_json, code: 200) }

  let(:discussion_topic) { DiscussionTopic.create}
  let!(:assignment) do
    Assignment.create(discussion_topic: discussion_topic, context: course)
  end

  let(:course) { Course.create }

  before do
    ENV['TOPIC_MICROSERVICE_ENDPOINT'] = 'endpoint'
    ENV['TOPIC_MICROSERVICE_API_KEY'] = 'key'
    allow(subject).to receive(:enrollments).and_return(enrollments)
    allow(HTTParty).to receive(:get).and_return(response)
  end

  describe '#get_teacher_unread_discussion_topics' do
    it 'is mixed in' do
      expect(subject).to respond_to(:get_teacher_unread_discussion_topics)
    end

    it 'calls the endpoint' do
      expect(HTTParty).to receive(:get).and_return(response)
      subject.get_teacher_unread_discussion_topics(course)
    end

    it 'returns a list of assignments' do
      expect(subject.get_teacher_unread_discussion_topics(course)).to eq [assignment]
    end


    context "missing configuration" do
      let(:enrollments) { double('enrollments', where: [])}

      before do
        ENV['TOPIC_MICROSERVICE_ENDPOINT'] = nil
        ENV['TOPIC_MICROSERVICE_API_KEY'] = nil
        allow(subject).to receive(:enrollments).and_return(enrollments)
      end

      it 'wont look up enrollments' do
        expect(enrollments).to_not receive(:where)
        subject.get_teacher_unread_discussion_topics(course) end

      it "wont call the service" do
        expect(HTTParty).to_not receive(:get)
        subject.get_teacher_unread_discussion_topics(course)
      end
    end
  end

  describe "#recent_feedback" do
    include_context "pipeline_context"

    it "returns only teacher-graded feedback" do
      computer_graded_submission = Submission.create(grader_id: 1)
      teacher_graded_submission = Submission.create(grader_id: 2)
      all_submissions = [computer_graded_submission, teacher_graded_submission]
      all_courses = [Course.create, Course.create]
      allow(subject).to receive(:participating_student_course_ids).and_return(all_courses)
      allow(subject).to receive(:submissions_for_context_codes).and_return(all_submissions)
      grader_ids = subject.recent_feedback.map(&:grader_id)
      expect(grader_ids).not_to include(1)
    end
  end
end
