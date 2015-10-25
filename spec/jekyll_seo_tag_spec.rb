require 'spec_helper'

describe Jekyll::SeoTag do

  subject { Jekyll::SeoTag.new("seo", nil, nil) }

  it "builds" do
    expect(subject.render(context)).to match(/Jekyll SEO tag/i)
  end

  it "builds the title with a page title only" do
     page = page({"title" => "foo"})
     context = context({ :page => page })
     expect(subject.render(context)).to match(/<title>foo<\/title>/)
     expect(subject.render(context)).to match(/<meta property="og:title" content="foo" \/>/)
  end

  it "builds the title with a page title and site title" do
     page = page({"title" => "foo"})
     site = site({"title" => "bar"})
     context = context({ :page => page, :site => site })
     expect(subject.render(context)).to match(/<title>foo - bar<\/title>/)
  end

  it "builds the title with only a site title" do
    site = site({"title" => "foo"})
    context = context({ :site => site })
    expect(subject.render(context)).to match(/<title>foo<\/title>/)
  end

  it "escapes titles" do
    site = site({"title" => "Jekyll & Hyde"})
    context = context({ :site => site })
    expect(subject.render(context)).to match(/<title>Jekyll &amp; Hyde<\/title>/)
  end

  it "uses the page description" do
    page = page({"description" => "foo"})
    context = context({ :page => page })
    expect(subject.render(context)).to match(/<meta name="description" content="foo" \/>/)
    expect(subject.render(context)).to match(/<meta property='og:description' content="foo" \/>/)
  end

  it "uses the site description when no page description exists" do
    site = site({"description" => "foo"})
    context = context({ :site => site })
    expect(subject.render(context)).to match(/<meta name="description" content="foo" \/>/)
    expect(subject.render(context)).to match(/<meta property='og:description' content="foo" \/>/)
  end

  it "uses the site url to build the seo url" do
    site = site({"url" => "http://example.invalid"})
    context = context({ :site => site })
    expected = /<link rel="canonical" href="http:\/\/example.invalid\/page.html" itemprop="url" \/>/
    expect(subject.render(context)).to match(expected)
    expected = /<meta property='og:url' content='http:\/\/example.invalid\/page.html' \/>/
    expect(subject.render(context)).to match(expected)
  end

  it "uses site.github.url to build the seo url" do
    site = site({"github" => { "url" => "http://example.invalid" }} )
    context = context({ :site => site })
    expected = /<link rel="canonical" href="http:\/\/example.invalid\/page.html" itemprop="url" \/>/
    expect(subject.render(context)).to match(expected)
    expected = /<meta property='og:url' content='http:\/\/example.invalid\/page.html' \/>/
    expect(subject.render(context)).to match(expected)
  end

  it "outputs the site title meta" do
    site = site({"title" => "Foo", "url" => "http://example.invalid"})
    context = context({ :site => site })
    output = subject.render(context)

    expect(output).to match(/<meta property="og:site_name" content="Foo" \/>/)
    data = output.match(/<script type=\"application\/ld\+json\">(.*)<\/script>/m)[1]

    data = JSON.parse(data)
    expect(data["name"]).to eql("Foo")
    expect(data["url"]).to eql("http://example.invalid")
  end

  it "outputs post meta" do
    post = post({"title" => "post", "description" => "description", "image" => "/img.png" })
    context = context({ :page => post })
    output = subject.render(context)
    expected = /<meta property="og:type" content="article" \/>/
    expect(output).to match(expected)
    data = output.match(/<script type=\"application\/ld\+json\">(.*)<\/script>/m)[1]
    data = JSON.parse(data)

    expect(data["headline"]).to eql("post")
    expect(data["description"]).to eql("description")
    expect(data["image"]).to eql("/img.png")
  end

  it "outputs twitter card meta" do
    site = site({"twitter" => { "username" => "jekyllrb" }})
    page = page({"author" => "benbalter"})
    context = context({ :site => site, :page => page })

    expected = /<meta name="twitter:site" content="@jekyllrb" \/>/
    expect(subject.render(context)).to match(expected)

    expected = /<meta name="twitter:creator" content="@benbalter" \/>/
    expect(subject.render(context)).to match(expected)
  end

  it "outputs social meta" do
    links = ["http://foo.invalid", "http://bar.invalid"]
    site = site({"social" => { "name" => "Ben", "links" => links }})
    context = context({ :site => site })
    output = subject.render(context)
    data = output.match(/<script type=\"application\/ld\+json\">(.*)<\/script>/m)[1]
    data = JSON.parse(data)

    expect(data["@type"]).to eql("person")
    expect(data["name"]).to eql("Ben")
    expect(data["sameAs"]).to eql(links)
  end

  it "outputs the logo" do
    site = site({"logo" => "logo.png", "url" => "http://example.invalid" })
    context = context({ :site => site })
    output = subject.render(context)
    data = output.match(/<script type=\"application\/ld\+json\">(.*)<\/script>/m)[1]
    data = JSON.parse(data)

    expect(data["logo"]).to eql("http://example.invalid/logo.png")
    expect(data["url"]).to eql("http://example.invalid")
  end

  it "outputs the image" do
    page = page({"image" => "http://foo.invalid/foo.png"})
    context = context({ :page => page })
    expected = /<meta property="og:image" content="http:\/\/foo.invalid\/foo.png" \/>/
    expect(subject.render(context)).to match(expected)
  end
end