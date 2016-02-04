require File.expand_path('spec_helper', File.dirname(__FILE__))
require_relative '../modifier'

# I could've put tests into single test, but I decided to go more granular strategy,
# so when something breaks we get to what exactly gone wrong.
describe Modifier do
  let(:combiner) { Combiner.new(&key_extractor) }

  describe "#modify" do

    after(:each) do
      # Do cleanup after Modifier.modify
      File.delete("spec/fixtures/output_0.txt")
      File.delete("spec/fixtures/correct_input.txt.sorted")
    end

    context "when called with correct input data" do
      let(:modifier) { Modifier.new(modification_factor: 0.5, cancellation_factor: 0.5) }
      it "should generate output files" do
        input = "spec/fixtures/correct_input.txt"
        output = "spec/fixtures/output.txt"
        modifier.modify(output, input)

        expect(File.exist?("spec/fixtures/output_0.txt")).to eq(true)
        expect(File.exist?("spec/fixtures/correct_input.txt.sorted")).to eq(true)
      end

      it "should generate output file which is sorted by 'Clicks'" do
        input = "spec/fixtures/correct_input.txt"
        output = "spec/fixtures/output.txt"
        modifier.modify(output, input)

        expect(File.exist?("spec/fixtures/output_0.txt")).to eq(true)
        expect(CSVHelper.parse("spec/fixtures/output_0.txt").size).to eq(3)
        expect(CSVHelper.parse("spec/fixtures/output_0.txt")[0]['Clicks']).to eq('10')
        expect(CSVHelper.parse("spec/fixtures/output_0.txt")[1]['Clicks']).to eq('4')
        expect(CSVHelper.parse("spec/fixtures/output_0.txt")[2]['Clicks']).to eq('2')
      end

      it "should generate output file with correct headers" do
        input = "spec/fixtures/correct_input.txt"
        output = "spec/fixtures/output.txt"
        modifier.modify(output, input)

        expect(File.exist?("spec/fixtures/output_0.txt")).to eq(true)
        expect(CSVHelper.parse("spec/fixtures/output_0.txt")[0].headers).
          to eq(["Account ID", "Account Name", "Campaign", "Ad Group", "Keyword", "Keyword Type",
                 "Subid", "Paused", "Max CPC", "Keyword Unique ID", "ACCOUNT", "CAMPAIGN",
                 "BRAND", "BRAND+CATEGORY", "ADGROUP", "KEYWORD", "Last Avg CPC", "Last Avg Pos",
                 "Clicks", "Impressions", "ACCOUNT - Clicks", "CAMPAIGN - Clicks", "BRAND - Clicks",
                 "BRAND+CATEGORY - Clicks", "ADGROUP - Clicks", "KEYWORD - Clicks", "Avg CPC", "CTR",
                 "Est EPC", "newBid", "Costs", "Avg Pos", "number of commissions", "Commission Value",
                 "ACCOUNT - Commission Value", "CAMPAIGN - Commission Value", "BRAND - Commission Value",
                 "BRAND+CATEGORY - Commission Value", "ADGROUP - Commission Value", "KEYWORD - Commission Value"])
      end

      it "should generate output with correct data" do
        input = "spec/fixtures/correct_input.txt"
        output = "spec/fixtures/output.txt"
        modifier.modify(output, input)

        expect(File.exist?("spec/fixtures/output_0.txt")).to eq(true)
        expect(CSVHelper.parse("spec/fixtures/output_0.txt")[0]['Account ID']).to eq('a')
        expect(CSVHelper.parse("spec/fixtures/output_0.txt")[1]['Account ID']).to eq('a')
        expect(CSVHelper.parse("spec/fixtures/output_0.txt")[2]['Account ID']).to eq('a')

        expect(CSVHelper.parse("spec/fixtures/output_0.txt")[0]['Keyword Unique ID']).to eq('ku1')
        expect(CSVHelper.parse("spec/fixtures/output_0.txt")[1]['Keyword Unique ID']).to eq('ku')
        expect(CSVHelper.parse("spec/fixtures/output_0.txt")[2]['Keyword Unique ID']).to eq('ku')

        expect(CSVHelper.parse("spec/fixtures/output_0.txt")[0]['Last Avg CPC']).to eq('1')
        expect(CSVHelper.parse("spec/fixtures/output_0.txt")[1]['Last Avg CPC']).to eq('1')
        expect(CSVHelper.parse("spec/fixtures/output_0.txt")[2]['Last Avg CPC']).to eq('1')

        expect(CSVHelper.parse("spec/fixtures/output_0.txt")[0]['number of commissions']).to eq('0,5')
        expect(CSVHelper.parse("spec/fixtures/output_0.txt")[1]['number of commissions']).to eq('0,5')
        expect(CSVHelper.parse("spec/fixtures/output_0.txt")[2]['number of commissions']).to eq('0,5')

        expect(CSVHelper.parse("spec/fixtures/output_0.txt")[0]['Commission Value']).to eq('0,25')
        expect(CSVHelper.parse("spec/fixtures/output_0.txt")[1]['Commission Value']).to eq('0,25')
        expect(CSVHelper.parse("spec/fixtures/output_0.txt")[2]['Commission Value']).to eq('0,25')
      end
    end

  end
end
