package com.bridgetec.common.osu.veloce;

import com.bridgetec.common.osu.veloce.ByteUtil;
import com.bridgetec.common.osu.veloce.LEByteUtil;
import com.bridgetec.common.osu.veloce.SocketClient;


public class OSUBody_2800 implements Body {
	private short delKind;
	private short systemId;
	private short processId;
	private String errKey;

	public final int BODY_LEN = 22;
	private int[] len = {2, 2, 2, 16};
	
	@Override
	public String toString(){
		StringBuffer buff = new StringBuffer();
		buff.append("BODY=[\n");
		buff.append("\t delKind  		 : ").append(delKind).append("\n");
		buff.append("\t systemId 	 : ").append(systemId).append("\n");
		buff.append("\t processId     : ").append(processId).append("\n");
		buff.append("\t errKey     : ").append(errKey).append("\n");
		buff.append("]\n");
		return buff.toString();
	}
	
	@Override
	public Body clone(){
		OSUBody_2800 body = new OSUBody_2800();
		body.setDelKind(delKind);
		body.setSystemId(systemId);
		body.setProcessId(processId);
		body.setErrKey(errKey);
		return body;
	}
	
	public OSUBody_2800(){}
	
	public OSUBody_2800(byte[] data){
		toObject(data);
	}
	
	public OSUBody_2800(int byteOrder, byte[] data){
		toObject(byteOrder, data);
	}

	@Override
	public byte[] toByte(){
		return toByte(SocketClient.BYTE_ORDER_BIG);
	}
	
	@Override
	public byte[] toByte(int byteOrder){
		return toByte(byteOrder, new byte[BODY_LEN]);
	}
	
	@Override
	public byte[] toByte(int byteOrder, byte[] buffer){
		return toByte(byteOrder, buffer, 0);
	}
	
	@Override
	public byte[] toByte(int byteOrder, byte[] buffer, int offset){
		int idx = 0;
		int startIdx = offset;

		if( byteOrder == SocketClient.BYTE_ORDER_BIG ){
			ByteUtil.fillInBuff(buffer, startIdx                  , len[idx  ], ByteUtil.short2byte( delKind ) );
			ByteUtil.fillInBuff(buffer, startIdx+=len[idx++], len[idx  ], ByteUtil.short2byte( systemId ) );
			ByteUtil.fillInBuff(buffer, startIdx+=len[idx++], len[idx  ], ByteUtil.short2byte( processId ) );
			ByteUtil.fillInBuff(buffer, startIdx+=len[idx++], len[idx  ], errKey);
		}
		else{
			ByteUtil.fillInBuff(buffer, startIdx                  , len[idx  ], LEByteUtil.shortToByte( delKind ) );
			ByteUtil.fillInBuff(buffer, startIdx+=len[idx++], len[idx  ], LEByteUtil.shortToByte( systemId ) );
			ByteUtil.fillInBuff(buffer, startIdx+=len[idx++], len[idx  ], LEByteUtil.shortToByte( processId ) );
			ByteUtil.fillInBuff(buffer, startIdx+=len[idx++], len[idx  ], errKey);
		}
		
		return buffer;
	}
	
	@Override
	public void toObject(byte[] data){
		toObject(SocketClient.BYTE_ORDER_BIG, data);
	}
	
	@Override
	public void toObject(int byteOrder, byte[] data){
		int idx = 0;
		int startIdx = 0;
		
		if( byteOrder == SocketClient.BYTE_ORDER_BIG ){
			delKind 		= ByteUtil.getshort(ByteUtil.getbytes(data, startIdx                , len[idx  ]), 0);
			systemId 	= ByteUtil.getshort(ByteUtil.getbytes(data, startIdx+=len[idx++], len[idx  ]), 0);
			processId 	= ByteUtil.getshort(ByteUtil.getbytes(data, startIdx+=len[idx++], len[idx  ]), 0);
			errKey 		= new String(       ByteUtil.getbytes(data, startIdx+=len[idx++], len[idx  ])   );
		}
		else{
			delKind 		= LEByteUtil.byteToShort(ByteUtil.getbytes(data, startIdx                     , len[idx  ]), 0);
			systemId 	= LEByteUtil.byteToShort(ByteUtil.getbytes(data, startIdx+=len[idx++], len[idx  ]), 0);
			processId 	= LEByteUtil.byteToShort(ByteUtil.getbytes(data, startIdx+=len[idx++], len[idx  ]), 0);
			errKey 		= new String(						  ByteUtil.getbytes(data, startIdx+=len[idx++], len[idx  ])   );
		}
	}
	
	@Override
	public int getBodyLen(){
		return BODY_LEN;
	}

	public short getDelKind() {
		return delKind;
	}

	public void setDelKind(short delKind) {
		this.delKind = delKind;
	}

	public short getSystemId() {
		return systemId;
	}

	public void setSystemId(short systemId) {
		this.systemId = systemId;
	}

	public short getProcessId() {
		return processId;
	}

	public void setProcessId(short processId) {
		this.processId = processId;
	}

	public String getErrKey() {
		return errKey;
	}

	public void setErrKey(String errKey) {
		this.errKey = errKey;
	}

	
	
	
}
	