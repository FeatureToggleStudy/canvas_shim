describe ContextModuleItem do
  include_context "stubbed_network"
  context 'callbacks' do
    describe 'before_commit' do
      let!(:context_module_item) { ContextModuleItem.create }
      it 'publishes to the pipeline, with an alias' do
        expect(PipelineService).to receive(:publish).with(context_module_item, alias: 'module_item')
        context_module_item.update(context_id: 54)
      end
    end
  end
end
