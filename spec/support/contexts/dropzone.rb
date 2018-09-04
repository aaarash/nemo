shared_context "dropzone" do
  def drop_in_dropzone(file_path)
    # Generate a fake input selector
    page.execute_script <<-JS
      fakeFileInput = window.$('<input/>').attr(
        {id: 'fakeFileInput', type:'file'}
      ).appendTo('body');
    JS
    # Attach the file to the fake input selector with Capybara
    attach_file("fakeFileInput", file_path)
    # Trigger the fake drop event
    page.execute_script <<-JS
      var e = jQuery.Event('drop', { dataTransfer : { files : [fakeFileInput.get(0).files[0]] } });
      $('.dropzone')[0].dropzone.listeners[0].events.drop(e);
    JS

    # If we don't wait for the upload to finish and another request is processed
    # in the meantime, it can lead to weird failures.
    wait_for_dropzone_upload

    page.execute_script <<-JS
      fakeFileInput.remove();
    JS
  end

  private

  def wait_for_dropzone_upload
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until dropzone_ready?
    end
  end

  def dropzone_ready?
    page.evaluate_script("ELMO.mediaUploaderManager.is_uploading()")
  end
end
