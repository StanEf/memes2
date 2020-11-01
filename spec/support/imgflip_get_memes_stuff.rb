shared_context(:imgflip_get_memes) do
  let(:imgflip_get_memes) do
    [
      {'id'=>'181913649', 'name'=>'Drake Hotline Bling', 'url'=> Rails.root.join('spec', 'support', 'imgflip_get_memes_stuff', '30b1gx.jpg'), 'width'=>1200, 'height'=>1200, 'box_count'=>2}
    ]
  end

  let(:rubys3_client) { Aws::S3::Client.new }

  let(:existed_images_in_local_aws) do
    result = true

    imgflip_get_memes.each do |meme|
      image_not_exist =
        rubys3_client.get_object(
            bucket: ENV['MINIO_BUCKET'],
            key: meme['name']
        ).blank?

      result = false if image_not_exist
    end

    result
  end

  let(:delete_existed_images_in_local_aws) do
    imgflip_get_memes.each do |meme|
      rubys3_client.delete_object(
          bucket: ENV['MINIO_BUCKET'],
          key: meme['name']
      )
    end
  end
end