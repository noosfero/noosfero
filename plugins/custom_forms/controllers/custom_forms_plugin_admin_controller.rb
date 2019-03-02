require 'zip'

class CustomFormsPluginAdminController < AdminController
  before_action :set_profiles

  def index; end

  def download_files
    profiles = @profiles.where(id: params[:profile_ids])

    if profiles.blank?
      session[:notice] = _('There is no data to be downloaded')
      redirect_to action: :index
      return
    end

    zip_data = ::Zip::OutputStream.write_buffer do |stream|
      profiles.each do |profile|
        profile.forms.map do |form|
          handler = CustomFormsPlugin::CsvHandler.new(form, params[:fields])
          csv_content = handler.generate_csv
          type = _(form.kind).capitalize

          stream.put_next_entry "#{profile.name} #{type} - #{form.name}.csv"
          stream.write csv_content
        end
      end
    end

    timestamp = DateTime.now.strftime('%Y-%m-%d %H+%M')
    send_data zip_data.string, type: 'application/zip',
                               filename: "#{_('Queries report - %s') %
                                            timestamp}.zip"
  end

  private

  def set_profiles
    @profiles = environment.profiles.joins(:forms).distinct
  end
end
