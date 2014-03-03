require 'spec_helper'

# see test_models.rb
class User
  extend PoorManSearch::Searchable
  string_search :name, :email
  number_search :rank
  time_search :registered_at
end

class Comment
  extend PoorManSearch::Searchable
  string_search :said
  number_search :count
end

describe PoorManSearch::Searchable do
  let(:user1){ User.create(email: "taro@yamada.example.com",
                           name: "山田太郎",
                           rank: 1,
                           registered_at: Time.parse('2013-12-31 23:21:11')) }

  let(:user2){ User.create(email: "hana@yamada.example.com",
                           name: "山田華",
                           rank: 3,
                           registered_at: Time.parse('2014-2-28 3:15:00')) }

  let(:user3){ User.create(email: "chad@miller.example.com",
                           name: "Chad Miller",
                           rank: 1,
                           registered_at: Time.parse('2014-2-28 16:23:15')) }

  let(:users){ [user1, user2, user3] }
  before{ users }

  describe "::search" do

    subject{ User.search search_string }

    shared_examples_for "User#search" do
      it "should get records match search string" do
        subject.count.should == expected_hits.count
        expected_hits.each{|user| subject.map(&:email).should be_include user.email }
      end
    end

    describe "string field search" do
      context "single word" do
        let(:search_string){ "yamada" }
        let(:expected_hits){ [user1, user2] }
        it_behaves_like "User#search"
      end

      context "multiple words" do
        let(:search_string){ "yamada 太郎" }
        let(:expected_hits){ [user1] }
        it_behaves_like "User#search"
      end
    end

    describe "number field search" do
      let(:search_string){ "1" }
      let(:expected_hits){ [user1, user3] }
      it_behaves_like "User#search"
    end

    describe "time field search" do
      context "date" do
        let(:search_string){ "2/28" }
        let(:expected_hits){ [user2, user3] }
        it_behaves_like "User#search"
      end

      context "datetime" do
        let(:search_string){ "2/28-3:15" }
        let(:expected_hits){ [user2] }
        it_behaves_like "User#search"
      end
    end

    describe "types mix" do
      let(:search_string){ "example.com 3" }
        let(:expected_hits){ [user2] }
        it_behaves_like "User#search"
    end
  end

  describe "::associative_search" do
    before{
      user1.say "どうもどうも"
      user2.say "あら遅いじゃない"
      user3.say "now?"
      user1.say "なんだって!?"
      user2.say "どうどう"
      user1.say "馬?"
    }

    subject{ User.associative_search search_string, :comments }

    shared_examples_for "User#associative_search" do
      it "should get records match search string" do
        subject.count.should == expected_hits.count
        expected_hits.each{|user| subject.map(&:email).should be_include user.email }
      end
    end

    context "associate entity search case1" do
      let(:search_string){ "どう" }
      let(:expected_hits){ [user1, user2] }
      it_behaves_like "User#associative_search"
    end

    context "associate entity search case2" do
      let(:search_string){ "?" }
      let(:expected_hits){ [user1, user3] }
      it_behaves_like "User#associative_search"
    end
  end
end
