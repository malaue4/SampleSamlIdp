module Management
  class SitesController < BaseController
    # add potential parent resources here
    # load_and_authorize_resource :parent

    before_action only: %i[show edit update destroy] do
      @site = Site.first_or_initialize
    end
    load_and_authorize_resource singleton: true # through: :parent

    # GET /site
    def show
    end

    # GET /site/new
    def new
    end

    # GET /site/edit
    def edit
    end

    # POST /site
    def create
      if @site.save
        redirect_to({ action: :show }, notice: "Site was successfully created.")
      else
        render :new, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /site
    def update
      if @site.update(site_params)
        redirect_to({ action: :show }, notice: "Site was successfully updated.", status: :see_other)
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /site
    def destroy
      @site.destroy!
      redirect_to({ action: :new }, notice: "Site was successfully destroyed.", status: :see_other)
    end

    private

      # Only allow a list of trusted parameters through.
      def site_params
        params.require(:site).permit(
          :entity_id,
          :organization_name,
          :organization_display_name,
          :organization_url,
          signing_certificates: [],
          encryption_certificates: [],
        )
      end
  end
end
