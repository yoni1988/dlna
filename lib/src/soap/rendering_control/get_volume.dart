import 'dart:convert';

import 'package:xml2json/xml2json.dart';

import '../../dlna_action_result.dart';
import '../../dlna_device.dart';
import '../soap_action.dart';

class GetVolume extends AbsDLNAAction<int> {
  GetVolume(DLNADevice? dlnaDevice) : super(dlnaDevice);

  @override
  Future<DLNAActionResult<int>> execute() async {
    DLNAActionResult<int> result = await start();
    if (result.success) {
      try {
        final myTransformer = Xml2Json();
        myTransformer.parse(result.httpContent!);
        String json = myTransformer.toParker();
        var source = jsonDecode(json);
        int volumeNum;
        var value = source['s:Envelope']['s:Body']['u:GetVolumeResponse']
            ['CurrentVolume'];
        if (value != null) {
          volumeNum = int.parse(value);
          result.result = volumeNum;
        }
      } catch (e) {
        result.success = false;
        result.errorMessage = e.toString();
      }
    }
    return result;
  }

  @override
  String? getControlURL() {
    return dlnaDevice!.description!.renderingControlControlURL;
  }

  @override
  String getSoapAction() {
    return '\"urn:schemas-upnp-org:service:RenderingControl:1#GetVolume\"';
  }

  @override
  String getXmlData() {
    return """<?xml version='1.0' encoding='utf-8' standalone='yes' ?>
<s:Envelope s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
	<s:Body>
		<u:GetVolume xmlns:u="urn:schemas-upnp-org:service:RenderingControl:1">
			<InstanceID>0</InstanceID>
			<Channel>Master</Channel>
		</u:GetVolume>
	</s:Body>
</s:Envelope>""";
  }
}
