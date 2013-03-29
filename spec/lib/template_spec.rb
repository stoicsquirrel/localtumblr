require 'spec_helper'
require 'nokogiri'
# require 'pry'

describe Localtumblr::Template do
  describe ".initialize" do
    it "requires a source template to be set" do
      expect { Localtumblr::Template.new }.to raise_error(ArgumentError)
    end
  end

  describe ".from_file" do
    let(:template) { Localtumblr::Template.from_file(File.join(File.dirname(__FILE__), "../support/tumblr-index.html")) }

    it "opens a file" do
      expect { template }.not_to raise_error(Errno::ENOENT)
    end

    it "reads a string from a file" do
      expect(template).not_to be_nil
    end

    it "parses a template and returns HTML" do
      new_template = template.parse
      expect(new_template).not_to be_nil
    end
  end

  describe "#parse" do
    let(:template) { Localtumblr::Template.from_file(File.join(File.dirname(__FILE__), "../support/tumblr-index.html")) }

    it "parses the source template and returns HTML" do
      expect(template.parse).not_to be_nil
    end

    context "in photo post" do
      let(:posts) do
        VCR.use_cassette('photo_posts') do
          # Get posts with exactly one photo.
          Localtumblr::Post.from_blog("bftech.tumblr.com", "5GPgmox9xWmFEyuLGwSh5xMJ0WMG7YhmtHsByRjSPnDc1prZNc", type: 'photo').select { |x| x[:photos].count == 1 }
        end
      end
      let(:template_with_photo_posts) do
        t = Localtumblr::Template.from_file(File.join(File.dirname(__FILE__), "../support/easy-reader-2.html.tmbl"))
        t.posts = posts
        t
      end

      it "expands the contents of a photo tag once for each photo in the page" do
        html_doc = Nokogiri::HTML(template_with_photo_posts.parse.to_s)
        html_doc_photos = html_doc.css("#posts > .post > .photo")
        expect(html_doc_photos).to have(posts.count).items
      end
    end
  end
end