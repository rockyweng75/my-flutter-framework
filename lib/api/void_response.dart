class VoidResponse {
  const VoidResponse();

  factory VoidResponse.fromJson(Map<String, dynamic> json) {
    // 假設後端無回傳資料，直接返回一個空的 VoidResponse
    return const VoidResponse();
  }

  Map<String, dynamic> toJson() {
    // 返回一個空的 JSON
    return {};
  }
}