part of alm.io;

///
///  * Socket Data Protocol
/// * [cmd,ack,data.size,data]
/// * Example:
/// *
/// *   1.client-> auth to ->server
/// *   2.client receive [IoCommond.connected,0,data.size,data] or [IoCommond.denied,0,data.size,data]
/// *   3.client send [IoCommond.file,0,data.size,data]
/// *   4.server receive [IoCommond.file,1,data.size,data]


