# frozen_string_literal: true
RSpec.configure do |config|
  config.before(datacite_api: true) do
    # ANY <API_BASE>/.*
    # With bad credentials
    stub_request(:any, /#{Regexp.quote(Hyrax::DOI::DataCiteClient::TEST_BASE_URL)}.*/)
      .to_return(status: 404, body: '{"errors":[{"status":"404","title":"The resource you are looking for doesn\'t exist."}]}')

    # ANY <MDS_BASE>/.*
    # With bad credentials
    stub_request(:any, /#{Regexp.quote(Hyrax::DOI::DataCiteClient::TEST_MDS_BASE_URL)}.*/)
      .to_return(status: 401)

    # POST <API_BASE>/dois/
    # Create draft doi
    stub_request(:post, URI.join(Hyrax::DOI::DataCiteClient::TEST_BASE_URL, "dois"))
      .with(headers: { "Content-Type" => "application/vnd.api+json" },
            basic_auth: ['username', 'password'],
            body: "{\"data\":{\"type\":\"dois\",\"attributes\":{\"prefix\":\"#{prefix}\"}}}")
      .to_return(status: 201, body: "{\"data\":{\"id\":\"#{prefix}/draft-doi\",\"type\":\"dois\",\"attributes\":{\"doi\":\"#{prefix}/draft-doi\",\"prefix\":\"#{prefix}\",\"suffix\":\"draft-doi\",\"identifiers\":[],\"alternateIdentifiers\":[],\"creators\":[],\"titles\":null,\"publisher\":null,\"container\":{},\"publicationYear\":null,\"subjects\":[],\"contributors\":[],\"dates\":[],\"language\":null,\"types\":{},\"relatedIdentifiers\":[],\"sizes\":[],\"formats\":[],\"version\":null,\"rightsList\":[],\"descriptions\":[],\"geoLocations\":[],\"fundingReferences\":[],\"xml\":null,\"url\":null,\"contentUrl\":null,\"metadataVersion\":0,\"schemaVersion\":null,\"source\":null,\"isActive\":false,\"state\":\"draft\",\"reason\":null,\"landingPage\":null,\"viewCount\":0,\"viewsOverTime\":[],\"downloadCount\":0,\"downloadsOverTime\":[],\"referenceCount\":0,\"citationCount\":0,\"citationsOverTime\":[],\"partCount\":0,\"partOfCount\":0,\"versionCount\":0,\"versionOfCount\":0,\"created\":\"2020-08-10T20:58:59.000Z\",\"registered\":null,\"published\":\"\",\"updated\":\"2020-08-10T20:58:59.000Z\"},\"relationships\":{\"client\":{\"data\":{\"id\":\"client-id\",\"type\":\"clients\"}},\"media\":{\"data\":{\"id\":\"#{prefix}/draft-doi\",\"type\":\"media\"}},\"references\":{\"data\":[]},\"citations\":{\"data\":[]},\"parts\":{\"data\":[]},\"partOf\":{\"data\":[]},\"versions\":{\"data\":[]},\"versionOf\":{\"data\":[]}}}}")

    # DELETE <MDS_BASE>/doi/<prefix>/draft-doi
    # Delete draft doi
    stub_request(:delete, URI.join(Hyrax::DOI::DataCiteClient::TEST_MDS_BASE_URL, "doi/#{prefix}/draft-doi"))
      .with(basic_auth: ['username', 'password'])
      .to_return(status: 200, body: '{"errors":[{"status":"405", "title":"Method not allowed"}]}')

    # DELETE <MDS_BASE>/doi/<prefix>/findable-doi
    # Delete draft doi with findable doi
    stub_request(:delete, URI.join(Hyrax::DOI::DataCiteClient::TEST_MDS_BASE_URL, "doi/#{prefix}/findable-doi"))
      .with(basic_auth: ['username', 'password'])
      .to_return(status: 405, body: '{"errors":[{"status":"405", "title":"Method not allowed"}]}')

    # GET <MDS_BASE>/metadata/<prefix>/draft-doi
    # Get doi metadata
    stub_request(:get, URI.join(Hyrax::DOI::DataCiteClient::TEST_MDS_BASE_URL, "metadata/#{prefix}/draft-doi"))
      .with(basic_auth: ['username', 'password'])
      .to_return(status: 200, body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
    <resource xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns=\"http://datacite.org/schema/kernel-4\" xsi:schemaLocation=\"http://datacite.org/schema/kernel-4 http://schema.datacite.org/meta/kernel-4/metadata.xsd\">
      <identifier identifierType=\"DOI\">#{prefix}/draft-doi</identifier>
      <creators>
        <creator>
          <creatorName>Chris Colvard</creatorName>
        </creator>
      </creators>
      <titles>
        <title>Test datacite registration work</title>
      </titles>
      <publisher>Ubiquity Press</publisher>
      <publicationYear>2020</publicationYear>
      <resourceType resourceTypeGeneral=\"Other\">GenericWork</resourceType>
      <sizes/>
      <formats/>
      <version/>
    </resource>")

    # GET <MDS_BASE>/metadata/<prefix>/unknown-doi
    # Get doi metadata with unknown doi
    stub_request(:get, URI.join(Hyrax::DOI::DataCiteClient::TEST_MDS_BASE_URL, "metadata/#{prefix}/unknown-doi"))
      .with(basic_auth: ['username', 'password'])
      .to_return(status: 404, body: 'DOI is unknown to MDS')

    # PUT <MDS_BASE>/metadata/<prefix>
    # Create new draft doi with metadata
    stub_request(:put, URI.join(Hyrax::DOI::DataCiteClient::TEST_MDS_BASE_URL, "metadata/#{prefix}"))
      .with(headers: { 'Content-Type': 'application/xml;charset=UTF-8' },
            basic_auth: ['username', 'password'])
      .to_return(status: 201, body: "OK (#{prefix}/draft-doi)")

    # PUT <MDS_BASE>/metadata/<prefix>/draft-doi
    # Update metadata for draft doi
    stub_request(:put, URI.join(Hyrax::DOI::DataCiteClient::TEST_MDS_BASE_URL, "metadata/#{prefix}/draft-doi"))
      .with(headers: { 'Content-Type': 'application/xml;charset=UTF-8' },
            basic_auth: ['username', 'password'])
      .to_return(status: 201, body: "OK (#{prefix}/draft-doi)")

    # PUT <MDS_BASE>/metadata/unknown-prefix/unknown-doi
    # Update metadata for unknown doi
    stub_request(:put, URI.join(Hyrax::DOI::DataCiteClient::TEST_MDS_BASE_URL, "metadata/unknown-prefix/unknown-doi"))
      .with(headers: { 'Content-Type': 'application/xml;charset=UTF-8' },
            basic_auth: ['username', 'password'])
      .to_return(status: 403, body: 'Access is denied')

    # DELETE <MDS_BASE>/metadata/<prefix>/draft-doi
    # Update metadata for draft doi
    stub_request(:delete, URI.join(Hyrax::DOI::DataCiteClient::TEST_MDS_BASE_URL, "metadata/#{prefix}/draft-doi"))
      .with(basic_auth: ['username', 'password'])
      .to_return(status: 200, body: "OK")

    # GET <MDS_BASE>/doi/<prefix>/draft-doi
    # Get doi url
    stub_request(:get, URI.join(Hyrax::DOI::DataCiteClient::TEST_MDS_BASE_URL, "doi/#{prefix}/draft-doi"))
      .with(basic_auth: ['username', 'password'])
      .to_return(status: 200, body: "https://www.moomin.com/en/")

    # GET <MDS_BASE>/doi/<prefix>/unknown-doi
    # Get doi url with unknown doi
    stub_request(:get, URI.join(Hyrax::DOI::DataCiteClient::TEST_MDS_BASE_URL, "doi/#{prefix}/unknown-doi"))
      .with(basic_auth: ['username', 'password'])
      .to_return(status: 404, body: "DOI is unknown to MDS")

    # PUT <MDS_BASE>/doi/<prefix>/draft-doi
    # Update url for draft doi
    stub_request(:put, URI.join(Hyrax::DOI::DataCiteClient::TEST_MDS_BASE_URL, "doi/#{prefix}/draft-doi"))
      .with(headers: { 'Content-Type': 'text/plain;charset=UTF-8' },
            basic_auth: ['username', 'password'])
      .to_return(status: 201, body: "")

    # PUT <MDS_BASE>/doi/<prefix>/unknown-doi
    # Update url for unknown doi
    stub_request(:put, URI.join(Hyrax::DOI::DataCiteClient::TEST_MDS_BASE_URL, "doi/#{prefix}/unknown-doi"))
      .with(headers: { 'Content-Type': 'text/plain;charset=UTF-8' },
            basic_auth: ['username', 'password'])
      .to_return(status: 422, body: "Can't be blank")
  end
end
