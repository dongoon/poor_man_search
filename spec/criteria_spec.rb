require 'spec_helper'

describe PoorManSearch::Criteria do
  describe "::new" do
    it "should receive single params" do
      proc{PoorManSearch::Criteria.new("abc")}.should_not raise_error
    end

    it "should receive single params nilable" do
      proc{PoorManSearch::Criteria.new}.should_not raise_error
      proc{PoorManSearch::Criteria.new(nil)}.should_not raise_error
    end

    it "should not receive multi params" do
      proc{PoorManSearch::Criteria.new("a", "b")}.should raise_error(ArgumentError)
    end
  end

  describe "parse" do

    describe "time_parse" do
      let(:c){PoorManSearch::Criteria.new}
      context "time parsable string" do
        it "should return Time parsed object" do
          [
           "2/1",
           "12/31-12:54",
           "11:30",
          ].each{|s|
            c.send(:time_parse, s).should == Time.parse(s)
          }
        end
      end

      context "NOT time parsable string" do
        it "should return nil" do
          [
           "hoge",
           "1231",
           "13/9",
          ].each{|s|
            c.send(:time_parse, s).should be_nil
          }
        end
      end
    end

    describe "number_parse" do
      let(:c){PoorManSearch::Criteria.new}

      context "number parsable string" do
        it "should return BigDecimal object" do
          [
           "1",
           "134",
           "12.001",
           "11.",
           "-1.5",
          ].each{|s|
            c.send(:number_parse, s).should == BigDecimal.new(s)
          }
        end
      end

      context "NOT number parsable string" do
        it "should return nil" do
          [
           "hoge",
           "12/31",
           "1.3.9",
           "1..3",
          ].each{|s|
            c.send(:number_parse, s).should be_nil
          }
        end
      end
    end

    context "empty params" do
      let(:criteria){
        PoorManSearch::Criteria.new(@search_string)
      }

      before {
        criteria.strings = %w(hoge fuga)
        criteria.stringables = %w(1/2 2/2)
        criteria.numbers = [1, 2, 3]
        criteria.times = [Time.now, 1.day.ago, 2.day.since]
        criteria.time_range = [1.day.ago, Date.today]
      }
      it "should not raise error" do
        proc{
          criteria.send :parse, nil
        }.should_not raise_error
      end

      it "should make properties to nil" do
        criteria.strings.count.should == 2
        criteria.send :parse, nil
        criteria.strings.should  == []
        criteria.stringables.should == []
        criteria.times.should == []
        criteria.time_range.should == []
      end
    end

    describe "strings" do
      context "single word" do
        it "should be [sing_word]" do
          criteria = PoorManSearch::Criteria.new "あれ"
          criteria.strings.count.should == 1
          criteria.strings.should == ["あれ"]
        end
      end

      context "multi words" do
        it "should be [word1, word2]" do
          criteria = PoorManSearch::Criteria.new " あれ　hoge\tどれ\nmore a "
          criteria.strings.count.should == 5
          criteria.strings.should == ["あれ", "hoge", "どれ", "more", "a"]
        end
      end

      context "with word be parsable other type" do
        it "should be [word(!number & !time)..]" do
          criteria = PoorManSearch::Criteria.new "あれ 1/2 どれ 123"
          criteria.strings.count.should == 2
          criteria.strings.should == ["あれ", "どれ"]
        end
      end
    end

    describe "numbers" do
      context "with numberable words" do
        it "should be [number..]" do
          criteria = PoorManSearch::Criteria.new "hoge 123 1.02 fuga 2"
          criteria.numbers.count.should == 3
          criteria.numbers.should  == [
                                       BigDecimal.new("123"),
                                       BigDecimal.new("1.02"),
                                       BigDecimal.new("2")
                                      ]
        end
      end

      context "without numberable word" do
        it "should be empty array" do
          criteria = PoorManSearch::Criteria.new "hoge 123/3 1.r fuga "
          criteria.numbers.should == []
        end
      end
    end

    describe "times" do
      context "with timable words" do
        it "should be [time..]" do
          criteria = PoorManSearch::Criteria.new "hoge 1/2 2/10-10:13 fuga 2/2"
          criteria.times.count.should == 3
          criteria.times.should  == [
                                     Time.parse("1/2"),
                                     Time.parse("2/10-10:13"),
                                     Time.parse("2/2")
                                    ]
        end
      end

      context "without timable word" do
        it "should be empty array" do
          criteria = PoorManSearch::Criteria.new "hoge 1233 1.r fuga "
          criteria.times.should == []
        end
      end
    end

    describe "time_range" do
      context "with two or more timable words" do
        it "should be [min, max]" do
          criteria = PoorManSearch::Criteria.new "2/2 1/10 hoge 1/15"
          criteria.time_range.count.should == 2
          criteria.time_range.should == [
                                         Time.parse("1/10"),
                                         Time.parse("2/2")
                                        ]
        end
      end

      context "with one or less timable words" do
        it "should be empty array" do
          criteria = PoorManSearch::Criteria.new "2/2"
          criteria.time_range.count.should == 0
        end
      end
    end
  end
end
