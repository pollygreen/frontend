require 'govuk_schemas'
require "gds_api/test_helpers/content_store"

module ContentStoreHelpers
  include GdsApi::TestHelpers::ContentStore

  def content_store_has_example_item(base_path, schema:, example: nil, is_tagged_to_taxon: false)
    content_item = GovukSchemas::Example.find(schema, example_name: example || schema)

    content_item['links'] ||= {}
    content_item['links']['taxons'] = is_tagged_to_taxon ? [basic_taxon] : []
    content_item['base_path'] = base_path

    content_store_has_item(base_path, content_item)
    content_item
  end

  def basic_taxon
    {
      "content_id" => "30c1b93d-2553-47c9-bc3c-fc5b513ecc32",
      "locale" => "en",
      "title" => "A Taxon",
      "base_path" => "/a-taxon",
    }
  end

  def content_store_has_random_item(base_path:, schema: 'placeholder', is_tagged_to_taxon: false)
    content_item = GovukSchemas::RandomExample.for_schema(frontend_schema: schema) do |item|
      taxons = is_tagged_to_taxon ? [basic_taxon] : []
      item.merge(
        'base_path' => base_path,
        'links' => { 'taxons' => taxons }
      )
    end

    content_store_has_item(content_item['base_path'], content_item)
    content_item
  end

  def content_store_has_item_tagged_to_taxon(base_path:, payload:)
    content_item = payload.merge(
      base_path: base_path,
      links: { taxons: [basic_taxon] }
    )
    content_store_has_item(base_path, content_item)
  end

  def content_store_has_page(slug, schema: 'placeholder', is_tagged_to_taxon: false)
    content_store_has_random_item(base_path: "/#{slug}", schema: schema, is_tagged_to_taxon: is_tagged_to_taxon)
  end

  def content_store_does_not_have_page(slug)
    content_store_does_not_have_item("/#{slug}")
  end

  def content_store_has_unpublished_page(slug)
    content_store_has_random_item(base_path: "/#{slug}")
  end

  def content_store_throws_exception_for(path, exception)
    Services.content_store.stubs(:content_item).with(path).raises(exception)
  end

  def content_store_has_archived_page(slug)
    content_store_has_gone_item("/#{slug}")
  end
end
