# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:cs_property).provider(:crm) do
  before do
    allow(described_class).to receive(:command).with(:crm).and_return('crm')
  end

  context 'when getting instances' do
    let :instances do
      test_cib = <<-EOS
        <cib>
          <configuration>
            <crm_config>
              <cluster_property_set id="cib-bootstrap-options">
                <nvpair name="apples" value="red"/>
                <nvpair name="oranges" value="orange"/>
              </cluster_property_set>
              <cluster_property_set id="redis_replication">
                <nvpair id="redis_replication-p_redis_REPL_INFO" name="p_redis_REPL_INFO" value="node-1"/>
              </cluster_property_set>
            </crm_config>
          </configuration>
        </cib>
      EOS

      allow(described_class).to receive(:block_until_ready).and_return(nil)
      allow(Puppet::Util::Execution).to receive(:execute).and_return(
        Puppet::Util::Execution::ProcessOutput.new(test_cib, 0)
      )
      described_class.instances
    end

    it 'has an instance for each <nvpair> in <cluster_property_set>' do
      expect(instances.count).to eq(2)
    end

    describe 'each instance' do
      let :instance do
        instances.first
      end

      it "is a kind of #{described_class.name}" do
        expect(instance).to be_a(described_class)
      end

      it "is named by the <nvpair>'s name attribute" do
        expect(instance.name).to eq('apples')
      end

      it "has a value corresponding to the <nvpair>'s value attribute" do
        expect(instance.value).to eq('red')
      end
    end
  end
end
