module Saml2
  NoSuchIssuerError = Class.new(StandardError)

  class Issuer
    attr_reader :id, :verify_signatures

    def initialize(id, verify_signatures)
      @id = id
      @verify_signatures = verify_signatures

      IssuerRegistry.register self
    end

    def verify_signatures?
      verify_signatures
    end
  end

  def self.Issuer(id)
    if IssuerRegistry.has_key? id
      IssuerRegistry[id]
    else
      raise NoSuchIssuerError, "No Issuer registered with id [#{id}]"
    end
  end

  IssuerRegistry = Class.new(Hash) do
    include SamlSp::Logging

    def register(issuer)
      self[issuer.id] = issuer
      logger.info "saml-sp: #{issuer.inspect}' registered"
    end
  end.new
end
