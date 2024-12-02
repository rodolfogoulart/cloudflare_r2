use cloudflare_r2_rs::r2::R2Manager;


#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

async fn get_r2_manager(
    bucket: &str,
    account_id: &str,
    access_id: &str,
    secret_access_key: &str,
) -> R2Manager {
    // "https://{account_id}.r2.cloudflarestorage.com",
    let url = format!("https://{account_id}.r2.cloudflarestorage.com");

    //Cloudflare
    let r2_manager = R2Manager::new(
        //Bucket Name
        &bucket,
        //Cloudflare URI endpoint
        &url,
        //API Token's Access Key ID
        &access_id,
        //API Token's Secret Access Key
        &secret_access_key,
    )
    .await;
    return r2_manager;
}

#[flutter_rust_bridge::frb(dart_async)]
pub async fn get_object(
    bucket: &str,
    account_id: &str,
    access_id: &str,
    secret_access_key: &str,
    object_name: &str,
) -> Vec<u8> {
    //Cloudflare
    let r2_manager = get_r2_manager(&bucket, &account_id, &access_id, &secret_access_key).await;

    return r2_manager.get(object_name).await.unwrap();
}

#[flutter_rust_bridge::frb(dart_async)]
/// if cache_control == "" then no cache defined
/// 
/// if content_type == "" then no content defined
pub async fn put_object(
    bucket: &str,
    account_id: &str,
    acess_id: &str,
    secret_acess_key: &str,
    object_name: &str,
    object_bytes: &[u8],
    cache_control: &str,
    content_type: &str,
){
    let mut _cache_control: Option<&str> = None;
    if cache_control != "" {
        _cache_control = Some(cache_control);
    }
    let mut _content_type: Option<&str> = None;
    if content_type != "" {
        _content_type = Some(content_type);
    }
    let r2_manager = get_r2_manager(&bucket, &account_id, &acess_id, &secret_acess_key).await;
    r2_manager
            .upload(object_name, object_bytes, _cache_control, _content_type)
            .await;
}

#[flutter_rust_bridge::frb(dart_async)]
pub async fn delete_object(
    bucket: &str,
    account_id: &str,
    access_id: &str,
    secret_access_key: &str,
    object_name: &str,
){
    let r2_manager = get_r2_manager(&bucket, &account_id, &access_id, &secret_access_key).await;
    r2_manager.delete(object_name).await;
}


