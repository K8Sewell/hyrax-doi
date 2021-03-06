# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::DOI::RegisterDOIJob, type: :job do
  let(:model_class) do
    Class.new(GenericWork) do
      include Hyrax::DOI::DOIBehavior
    end
  end
  let(:work) { model_class.create(title: ['Moomin']) }

  before do
    # Stubbed here for ActiveJob deserialization
    stub_const("WorkWithDOI", model_class)
  end

  describe '.perform_later' do
    before { ActiveJob::Base.queue_adapter = :test }

    it 'enqueues the job' do
      expect { described_class.perform_later(work) }
        .to enqueue_job(described_class)
        .with(work)
        .on_queue(Hyrax.config.ingest_queue_name)
    end
  end

  describe '.perform' do
    let(:registrar_class) do
      Class.new(Hyrax::Identifier::Registrar) do
        def initialize(*); end

        def register!(*)
          Struct.new(:identifier).new('10.1234/moomin/123/abc')
        end
      end
    end
    let(:doi) { ['10.1234/moomin/123/abc'] }
    let(:registrar) { :moomin }
    let(:registrar_opts) { { builder: 'CustomBuilderClass', connection: 'CustomConnectionClass' } }

    before do
      allow(Hyrax.config).to receive(:identifier_registrars).and_return(abstract: Hyrax::Identifier::Registrar, moomin: registrar_class)
      allow(registrar_class).to receive(:new).and_call_original
    end

    it 'calls the registrar' do
      expect { described_class.perform_now(work, registrar: registrar.to_s, registrar_opts: registrar_opts) }
        .to change { work.doi }
        .to eq doi
      expect(registrar_class).to have_received(:new).with(registrar_opts)
    end
  end
end
