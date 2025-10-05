class PwaController < ApplicationController
  def manifest
    respond_to do |format|
      format.json { render "pwa/manifest.json" }
    end
  end

  def service_worker
    respond_to do |format|
      format.js { render "pwa/service-worker.js" }
    end
  end
end
