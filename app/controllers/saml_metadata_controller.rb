class SamlMetadataController < ApplicationController
  # add potential parent resources here
  # load_and_authorize_resource :parent
  load_and_authorize_resource # through: :parent

  # GET /saml_metadata
  def index
    @pagy, @saml_metadata = pagy(@saml_metadata)
  end

  # GET /saml_metadata/1
  def show
  end

  # GET /saml_metadata/new
  def new
  end

  # GET /saml_metadata/1/edit
  def edit
  end

  # POST /saml_metadata
  def create
    if @saml_metadatum.save
      redirect_to @saml_metadatum, notice: "Saml metadatum was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /saml_metadata/1
  def update
    if @saml_metadatum.update(saml_metadatum_params)
      redirect_to @saml_metadatum, notice: "Saml metadatum was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /saml_metadata/1
  def destroy
    @saml_metadatum.destroy!
    redirect_to saml_metadata_url, notice: "Saml metadatum was successfully destroyed.", status: :see_other
  end

  private

    # Only allow a list of trusted parameters through.
    def saml_metadatum_params
      params.require(:saml_metadatum).permit(:entity_id, :metadata_url, :fingerprint, :validates_signature)
    end
end
