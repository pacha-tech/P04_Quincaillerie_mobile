

class CloudinaryService {

  String getThumbnailUrl(String? url) {
    if (url == null || url.isEmpty) return "";
    if (!url.contains("cloudinary.com")) return url;


    const String transformations = "/upload/w_150,h_150,c_fill,g_auto,q_auto,f_auto/";

    return url.replaceAll("/upload/", transformations);
  }
}
