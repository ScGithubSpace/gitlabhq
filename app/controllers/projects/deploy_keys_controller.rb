class Projects::DeployKeysController < Projects::ApplicationController
  respond_to :html

  # Authorize
  before_filter :authorize_admin_project!

  layout "project_settings"

  def index
    @enabled_keys = @project.deploy_keys
    @available_keys = available_keys - @enabled_keys
    @available_project_keys = current_user.project_deploy_keys - @enabled_keys
    @available_public_keys = DeployKey.are_public - @available_project_keys - @enabled_keys
  end

  def show
    @key = @project.deploy_keys.find(params[:id])
  end

  def new
    @key = @project.deploy_keys.new

    respond_with(@key)
  end

  def create
    @key = DeployKey.new(deploy_key_params)

    if @key.valid? && @project.deploy_keys << @key
      redirect_to namespace_project_deploy_keys_path(@project.namespace,
                                                     @project)
    else
      render "new"
    end
  end

  def enable
    @key = current_user.accessible_deploy_keys.find(params[:id])
    @project.deploy_keys << @key

    redirect_to namespace_project_deploy_keys_path(@project.namespace,
                                                   @project)
  end

  def disable
    @project.deploy_keys_projects.find_by(deploy_key_id: params[:id]).destroy

    redirect_to :back
  end

  protected

  def available_keys
    @available_keys ||= current_user.accessible_deploy_keys
  end

  def deploy_key_params
    params.require(:deploy_key).permit(:key, :title)
  end
end
