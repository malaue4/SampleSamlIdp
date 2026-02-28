SAML 2.0 Metadata Parsing TODO

This repository already parses several core SAML metadata components (SPSSODescriptor, IDPSSODescriptor, common endpoints/services, AttributeConsumingService, RequestedAttribute, NameIDFormat, etc.). The list below captures remaining parts of the SAML 2.0 metadata schema (saml-schema-metadata-2.0.xsd) that are not yet parsed or only partially covered, based on a review of the code under app/models/saml/metadata and the existing tests.

Conventions:
- Schema references are to SAML 2.0 Metadata schema components as defined in public/saml-schema-metadata-2.0.xsd.
- “Parse” means: expose accessors on the corresponding model, with Nokogiri extraction under .parse or lazy getters, and include in as_json where applicable.

Top-level: md:EntityDescriptor / md:EntitiesDescriptor
- EntityDescriptor attributes (EntityDescriptorType)
  - entityID attribute: Not parsed into Saml::Metadata::EntityDescriptor (entity_id attr exists but is not assigned from XML). Parse @ /md:EntityDescriptor/@entityID.
  - ID attribute: Not parsed. Parse optional @ID.
  - validUntil attribute: Not parsed but referenced by validations. Parse optional @validUntil.
  - cacheDuration attribute: Not parsed but referenced by validations. Parse optional @cacheDuration (xs:duration).
- EntityDescriptor children
  - <ds:Signature>: Not parsed.
  - <md:Extensions>: Not parsed (and not surfaced anywhere). Consider exposing raw XML or a generic container.
  - <md:RoleDescriptor>: Currently mapped to RoleDescriptor.parse but generic RoleDescriptor children and attributes (see RoleDescriptorType) are incomplete (see RoleDescriptor section below).
  - <md:SPSSODescriptor> and <md:IDPSSODescriptor>: Parsed (see below), but their common RoleDescriptorType children are incomplete (KeyDescriptor, Organization, ContactPerson, AdditionalMetadataLocation, Extensions, Signature).
  - <md:AuthnAuthorityDescriptor>: Not implemented (RoleDescriptor.parse raises NotImplementedError).
  - <md:AttributeAuthorityDescriptor>: Not implemented (NotImplementedError).
  - <md:PDPDescriptor>: Not implemented (NotImplementedError).
  - <md:AffiliationDescriptor>: Presence helper exists (affiliation_descriptor_element) but no parsing/model implemented.
  - <md:Organization>: Not parsed.
  - <md:ContactPerson>: Not parsed. Tests include ContactPerson presence; no model.
  - <md:AdditionalMetadataLocation>: Not parsed.
- EntitiesDescriptor (collection of entity descriptors): No parsing/model exists at all. If needed, add Saml::Metadata::EntitiesDescriptor to support aggregated metadata with nested EntitiesDescriptor and EntityDescriptor, plus its attributes (Name, validUntil, cacheDuration, ID) and children (Extensions, Signature, EntityDescriptor*, EntitiesDescriptor*).

RoleDescriptorType (common to IDPSSODescriptor, SPSSODescriptor, etc.)
- Attributes parsed: protocolSupportEnumeration, errorURL.
- Missing attributes:
  - validUntil, cacheDuration, ID (optional) — not parsed at RoleDescriptor level (even though SingleSignOnDescriptor inherits RoleDescriptor, so it would be suitable to parse here too).
- Missing children:
  - <ds:Signature> — not parsed.
  - <md:Extensions> — not parsed.
  - <md:KeyDescriptor> (0..*) — not parsed anywhere. Needs model: KeyDescriptor (type md:KeyDescriptorType) parsing @use (signing|encryption) and embedded ds:KeyInfo (algorithm, X509Data/X509Certificate), possibly as raw XML or structured minimal model (certificate text, use).
  - <md:Organization> — not parsed. Needs Organization model (OrganizationType) with OrganizationName, OrganizationDisplayName, OrganizationURL (xml:lang map similar to AttributeConsumingService service_name/description).
  - <md:ContactPerson> (0..*) — not parsed. Needs ContactPerson model (ContactType) with @contactType, Company, GivenName, SurName, EmailAddress*, TelephoneNumber*; may include Extensions.
  - <md:AdditionalMetadataLocation> (0..*) — not parsed. Needs model with @namespace and text (Location URI).

SPSSODescriptor (ServiceProviderSSODescriptorType)
- Implemented:
  - AuthnRequestsSigned?, WantAssertionsSigned?, AssertionConsumerService*, AttributeConsumingService*.
- Missing (from schema):
  - <md:ArtifactResolutionService>* — available via SingleSignOnDescriptor already (covered).
  - <md:SingleLogoutService>* — covered via SingleSignOnDescriptor.
  - <md:ManageNameIDService>* — covered via SingleSignOnDescriptor.
  - <md:NameIDFormat>* — covered via SingleSignOnDescriptor.
  - <md:AssertionConsumerService> — covered via class.
  - <md:AttributeConsumingService> — covered via class.
  - Note: SP also derives from RoleDescriptorType, so all RoleDescriptor missing parts apply (KeyDescriptor, Organization, ContactPerson, etc.).

IDPSSODescriptor (IDPSSODescriptorType)
- Implemented:
  - WantAuthnRequestsSigned?, SingleSignOnService*, NameIDMappingService*, AssertionIDRequestService*, AttributeProfile*, Attribute*.
  - And inherited from SingleSignOnDescriptor: ArtifactResolutionService*, SingleLogoutService*, ManageNameIDService*, NameIDFormat*.
- Missing (from schema):
  - As with SP: RoleDescriptorType children (KeyDescriptor, Organization, ContactPerson, etc.).
  - <md:NameIDMappingService> — implemented as NameIdMappingService (OK).
  - <md:AssertionIDRequestService> — implemented (OK).

Common Endpoint/Service models
- Endpoint, IndexedEndpoint parsing looks good for Binding, Location, ResponseLocation, index, isDefault.
- AttributeConsumingService: Parses ServiceName, ServiceDescription (per-lang hash), RequestedAttribute*, index, isDefault. OK.
- RequestedAttribute: Extends Attribute; parses isRequired. OK.

Attribute (saml:Attribute) within IDPSSODescriptor
- There is a Saml::Attribute model (not in Metadata namespace) referenced by IdentityProviderSingleSignOnDescriptor. Confirm coverage of Name, NameFormat, FriendlyName, AttributeValue*. If not fully parsed, consider adding TODO under saml:Attribute scope (but this is protocol/core, not metadata-specific). Note: current code references Attribute.parse; ensure it supports values.

AffiliationDescriptor
- No model. Schema requires @affiliationOwnerID and optional @ID, @validUntil, @cacheDuration, plus <AffiliateMember>* and optional <KeyDescriptor>* and <Organization>?, <ContactPerson>*, <Signature>, <Extensions>. Needs design if affiliation is in scope.

Signature (ds:Signature)
- Signature elements occur under EntityDescriptor, EntitiesDescriptor, RoleDescriptorType, and others. No parsing model present. At minimum, expose presence and raw XML; optionally capture certificate/key info via KeyDescriptor.

Extensions
- md:Extensions elements appear under EntityDescriptor/EntitiesDescriptor/RoleDescriptor and several child types (Organization, ContactPerson, AttributeConsumingService). No generic parsing. Consider exposing raw XML node(s) to callers.

AdditionalMetadataLocation
- Not parsed. Provide simple struct with @namespace and text content (URI).

NameIDPolicy (note: not metadata; appears in protocol requests)
- Out of scope for metadata parsing; mentioned here only for clarity.

Tests and validations alignment
- app/models/saml/metadata/entity_descriptor.rb has validations referencing cache_duration and valid_until but those readers are not implemented. Either implement parsing or adjust validations; for now, TODO to implement readers: valid_until, cache_duration and root? handling per schema.
- test/models/saml/metadata/entity_descriptor_test.rb includes ContactPerson in sample XML, but there is no code parsing ContactPerson. Add parser or explicitly document unsupported.

Prioritization suggestion
1) Implement EntityDescriptor attributes (entityID, validUntil, cacheDuration, ID) and expose ContactPerson(s) and Organization to support common metadata inspection use cases.
2) Implement RoleDescriptorType: KeyDescriptor parsing (extract X509Certificate and use), and surface Extensions/Signature as raw nodes.
3) Implement ContactPerson, Organization, AdditionalMetadataLocation models.
4) Consider AffiliationDescriptor and the remaining RoleDescriptor variants (AuthnAuthorityDescriptor, AttributeAuthorityDescriptor, PDPDescriptor) if needed for your deployments.

References
- public/saml-schema-metadata-2.0.xsd — authoritative schema used during review.
