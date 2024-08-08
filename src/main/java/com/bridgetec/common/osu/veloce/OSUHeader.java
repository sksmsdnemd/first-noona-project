package com.bridgetec.common.osu.veloce;

import com.bridgetec.common.osu.veloce.ByteUtil;
import com.bridgetec.common.osu.veloce.LEByteUtil;
import com.bridgetec.common.osu.veloce.SocketClient;

public class OSUHeader implements Header {
	
	public static final short CMD_VERSION_REQ = (short)3010;
	public static final short CMD_REALTIME_USER_DN_REQ = (short)3020;
	public static final short CMD_REALTIME_OAM_TIMECODE_REQ = (short)3030;
	public static final short OAM_MWU_SMS_PREVENT_REQ = (short)3040;
	public static final short OAM_CLIENT_CUR_ERR_DEL_REQ = (short)2800;

	private String token = "POAM";
	private short command;
	private short ackCode = (short)0x00;
	private int txId;
	private int length;

	public static final int HEADER_LEN = 16;
	private int[] len = {4, 2, 2, 4, 4};
	
	@Override
	public String toString(){
		StringBuffer buff = new StringBuffer();
		buff.append("HEADER=[\n");
		buff.append("\t TOKEN          : ").append(token).append("\n");
		buff.append("\t COMMAND        : ").append(command).append("\n");
		buff.append("\t ACKCODE        : ").append(ackCode).append("\n");
		buff.append("\t TRANSACTION ID : ").append(txId).append("\n");
		buff.append("\t LENGTH         : ").append(length).append("\n");
		buff.append("]\n");
		return buff.toString();
	}
	
	@Override
	public OSUHeader clone(){
		OSUHeader header = new OSUHeader();
		header.setCommand(command);
		header.setTxId(txId);
		header.setLength(length);
		return header;
	}
	
	public OSUHeader(){}
	
	public OSUHeader(byte[] data){
		toObject(data);
	}
	
	public OSUHeader(int byteOrder, byte[] data){
		toObject(byteOrder, data);
	}
	
	@Override
	public byte[] toByte(){
		return toByte(SocketClient.BYTE_ORDER_BIG);
	}
	
	@Override
	public byte[] toByte(int byteOrder){
		return toByte(byteOrder, new byte[HEADER_LEN]);
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
			ByteUtil.fillInBuff(buffer, startIdx            , len[idx  ], token                           );
			ByteUtil.fillInBuff(buffer, startIdx+=len[idx++], len[idx  ], ByteUtil.short2byte( command  ) );
			ByteUtil.fillInBuff(buffer, startIdx+=len[idx++], len[idx  ], ByteUtil.short2byte( ackCode ) );
			ByteUtil.fillInBuff(buffer, startIdx+=len[idx++], len[idx  ], ByteUtil.int2byte  ( txId     ) );
			ByteUtil.fillInBuff(buffer, startIdx+=len[idx++], len[idx  ], ByteUtil.int2byte  ( length   ) );
		}
		else{
			ByteUtil.fillInBuff(buffer, startIdx            , len[idx  ], token                                           );
			ByteUtil.fillInBuff(buffer, startIdx+=len[idx++], len[idx  ], LEByteUtil.shortToByte( command  ) );
			ByteUtil.fillInBuff(buffer, startIdx+=len[idx++], len[idx  ], LEByteUtil.shortToByte( ackCode ) );
			ByteUtil.fillInBuff(buffer, startIdx+=len[idx++], len[idx  ], LEByteUtil.intToByte  ( txId     ) );
			ByteUtil.fillInBuff(buffer, startIdx+=len[idx++], len[idx  ], LEByteUtil.intToByte  ( length   ) );
		}
		
		return buffer;
	}
	
	@Override
	public int getHeaderLen(){
		return HEADER_LEN;
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
			token 	= new String(       ByteUtil.getbytes(data, startIdx            , len[idx  ])   );
			command = ByteUtil.getshort(ByteUtil.getbytes(data, startIdx+=len[idx++], len[idx  ]), 0);
			ackCode = ByteUtil.getshort(ByteUtil.getbytes(data, startIdx+=len[idx++], len[idx  ]), 0);
			txId 	= ByteUtil.getint  (ByteUtil.getbytes(data, startIdx+=len[idx++], len[idx  ]), 0);
			length 	= ByteUtil.getint  (ByteUtil.getbytes(data, startIdx+=len[idx++], len[idx  ]), 0);
		}
		else{
			token 	= new String(						  ByteUtil.getbytes(data, startIdx            , len[idx  ])   );
			command = LEByteUtil.byteToShort(ByteUtil.getbytes(data, startIdx+=len[idx++], len[idx  ]), 0);
			ackCode = LEByteUtil.byteToShort(ByteUtil.getbytes(data, startIdx+=len[idx++], len[idx  ]), 0);
			txId 	= LEByteUtil.byteToInt  (ByteUtil.getbytes(data, startIdx+=len[idx++], len[idx  ]), 0);
			length 	= LEByteUtil.byteToInt  (ByteUtil.getbytes(data, startIdx+=len[idx++], len[idx  ]), 0);
		}
	}

	@Override
	public int getLength() {
		return length;
	}

	public void setLength(int length) {
		this.length = length;
	}

	public short getCommand() {
		return command;
	}

	public void setCommand(short command) {
		this.command = command;
	}

	public int getTxId() {
		return txId;
	}

	public void setTxId(int txId) {
		this.txId = txId;
	}

	public String getToken() {
		return token;
	}

	public void setToken(String token) {
		this.token = token;
	}

	public short getAckCode() {
		return ackCode;
	}

	public void setAckCode(short ackCode) {
		this.ackCode = ackCode;
	}

	public int[] getLen() {
		return len;
	}

	public void setLen(int[] len) {
		this.len = len;
	}
}
