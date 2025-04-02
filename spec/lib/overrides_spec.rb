# frozen_string_literal: true

require "spec_helper"

# We make sure that the checksum of the file overriden is the same
# as the expected. If this test fails, it means that the overriden
# file should be updated to match any change/bug fix introduced in the core
checksums = [
  {
    package: "decidim-core",
    files: {
      "/app/commands/decidim/create_registration.rb" => "c2fafd313dbe16624e3ef07584e946cd",
      "/app/commands/decidim/create_omniauth_registration.rb" => "5bca48c990c3b82d47119902c0a56ca1",
      "/app/commands/decidim/update_account.rb" => "d24090fdd9358c38e6e15c4607a78e18",
      "/app/models/decidim/organization.rb" => "a72b9d9ef10aa06dbe5aef27c68d5c7a",
      "/app/views/decidim/account/show.html.erb" => "f13218e2358a2d611996c2a197c0de25",
      "/app/views/decidim/devise/registrations/new.html.erb" => "b30423406afd43bb9af2c98d59d43632",
      "/app/views/decidim/devise/omniauth_registrations/new.html.erb" => "49f44efcd7ae6f87c04b309733ff28f6"
    }
  },
  {
    package: "decidim-admin",
    files: {
      "/app/views/decidim/admin/officializations/index.html.erb" => "e849c5dbaf04379bf233c15e860e1a18"
    }
  }
]

describe "Overriden files", type: :view do
  checksums.each do |item|
    spec = Gem::Specification.find_by_name(item[:package])
    item[:files].each do |file, signature|
      it "#{spec.gem_dir}#{file} matches checksum" do
        expect(md5("#{spec.gem_dir}#{file}")).to eq(signature)
      end
    end
  end

  private

  def md5(file)
    Digest::MD5.hexdigest(File.read(file))
  end
end
