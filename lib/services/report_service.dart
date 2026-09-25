import "dart:convert";
import "../models/report_summary.dart";
import "api_config.dart";
import "api_client.dart";

class ReportService {
  Future<ReportSummary?> getSummary() async {
    try {
      final res = await ApiClient.get("${ApiConfig.baseUrl}/reports/summary");
      if (res.statusCode != 200) return null;
      return ReportSummary.fromJson(jsonDecode(res.body));
    } catch (_) {
      return null;
    }
  }
}
