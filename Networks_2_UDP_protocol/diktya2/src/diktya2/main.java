package diktya2;

import java.net.*;
import java.util.ArrayList;
import java.awt.image.BufferedImage;
import java.io.*;

import javax.imageio.ImageIO;
import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.AudioFileFormat.Type;

public class main {

	public static void main(String[] args) throws IOException {
		//Parameters
		int clientLP = 48021; //my PC's port
		int serverLP = 38021; //ithaki
	
		String Echo = "E2693";
		String Image = "M4806CAM=PTZDIR=U";
		String Sound = "V4379";
		

		//UDP Socket object
		DatagramSocket s = new DatagramSocket(serverLP); //send
		DatagramSocket r = new DatagramSocket(clientLP); //receive
		r.setSoTimeout(5000); //5000ms timeout

		//Ithaki server IP
		byte[] ithakiIP = { (byte)155, (byte)207, (byte) 18, (byte) 208}; //155.207.18.208
		InetAddress ithaki = InetAddress.getByAddress(ithakiIP);

		String content;
		byte[] txBuffer;
		DatagramPacket p;

		//set UDP Packet content to echo request
		content = Echo;
		txBuffer = content.getBytes();
		p = new DatagramPacket(txBuffer, txBuffer.length, ithaki, serverLP);
		GetStrings(s, p, r);
	
		//set UDP Packet content to sound request
		content = Sound;
		String soundsrc = "F"; //T = sinewave, F = song
		int numPackets = 111; //number of packets requested
		content = content + soundsrc + numPackets;
		txBuffer = content.getBytes();
		p = new DatagramPacket(txBuffer, txBuffer.length, ithaki, serverLP);
		System.out.println(content);
		GetSound(s, p, r, numPackets);
		
		//set UDP Packet content to image request
		content = Image;
		txBuffer = content.getBytes();
		p = new DatagramPacket(txBuffer, txBuffer.length, ithaki, serverLP);
		GetImage(s, p, r);
	}

	private static void GetSound(DatagramSocket send, DatagramPacket p, DatagramSocket receive, int numPackets)
			throws IOException {
		
		byte[] rxBuffer = new byte[2048];
		DatagramPacket q = new DatagramPacket(rxBuffer, rxBuffer.length);
		
		System.out.println("About to receive a shitload of sound");
		ArrayList<Byte> sound = new ArrayList<Byte>(); //image size up to 800 KB
		int timeouts = 0;
		
		send.send(p);
		while(true){
			try {
				receive.receive(q);
				byte [] temp = decodeDPCM(rxBuffer, rxBuffer.length);
				int L = temp.length;
				for (int i = 0; i < L; i++){
					sound.add(temp[i]);
				}

			} catch (IOException e) {
				System.out.println(e);
				timeouts++;
				if (timeouts >= 4){
					//connection probably died or sound ended and we didn't catch it
					break;
				}
			}
		}
		if (sound.size() > 0){
			System.out.println("Received a shitload of sound");
			System.out.println("Specifically, "+ sound.size() + "bytes");

			byte[] temp = new byte[sound.size()];
			for (int i = 0; i < temp.length; i++){
				temp[i] = (byte) sound.get(i);
			}

			InputStream b_in = new ByteArrayInputStream(temp);
			DataOutputStream dos = new DataOutputStream(new FileOutputStream("filename.bin"));
			dos.write(temp);
			AudioFormat format = new AudioFormat(8000f, 16, 1, true, false);
			AudioInputStream stream = new AudioInputStream(b_in, format, temp.length);
			File file = new File("filename.wav");
			AudioSystem.write(stream,  Type.WAVE, file);
			System.out.println("Saved file");
		}
	}

	private static byte[] decodeDPCM(byte[] sound, int L) {
		int b = 1;
		int m = 0;
		byte[] result = new byte[2*L];
		result[1] = 1;
		
		for(int i = 0; i < L; i++){
			int low_nibble = (0b00001111 & sound[i]);
			//int high_nibble= ((0b11110000 & sound[i])>>4);
			int high_nibble= ((0b00001111 & ( sound[i])>>4) );

			result[2*i] = (byte) (result[2*i+1] + (low_nibble-8)*b);
			result[2*i+1] = (byte) (result[2*i] + (high_nibble-8)*b);
		}
		
		return result;
	}
	
	public byte[] dpcm(byte[] rxbuffer, int b, BufferedWriter bw, boolean freqgen, BufferedWriter bwf) {
		int freq, freq0 = 0;
		int D1, D2;
		int sample1, sample2;
		byte[] decoded = new byte[rxbuffer.length*Q/4];
		for(int i = 0; i < rxbuffer.length; i++) {
			D1 = ((rxbuffer[i] >>> 4) & 0x0F) - 8; //MS Nibble
			D2 = (rxbuffer[i] & 0x0F) - 8; //LS Nibble
			sample1 = sample0+D1*b;
			sample2 = sample1+D2*b;
			if(Q == 16) {
				if(sample1 > 32767) sample1 = 32767;
				else if(sample1 < -32768) sample1 = -32768;
				if(sample2 > 32767) sample2 = 32767;
				else if(sample2 < -32768) sample2 = -32768;
			}
			else {
				if(sample1 > 127) sample1 = 127;
				else if(sample1 < -128) sample1 = -128;
				if(sample2 > 127) sample2 = 127;
				else if(sample2 < -128) sample2 = -128;
			}
			sample0 = sample2;
			try {
				bw.write(D1+"\t\t"+sample1);
				bw.newLine();
				bw.write(D2+"\t\t"+sample2);
				bw.newLine();
			} catch (IOException e) {
				e.printStackTrace();
				System.exit(1);
			}
			if(Q == 16) {
				decoded[4*i] = (byte) (sample1 & 0xFF);
				decoded[4*i+1] = (byte) ((sample1 >>> 8) & 0xFF);
				decoded[4*i+2] = (byte) (sample2 & 0xFF);
				decoded[4*i+3] = (byte) ((sample2 >>> 8) & 0xFF);
			}
			else {
				decoded[2*i] = (byte) (sample1 & 0xFF);
				decoded[2*i+1] = (byte) (sample2 & 0xFF);
			}
			if(freqgen) {
				scount += 2;
				D0 = D2;
				if((D1 > 0 && D2 < 0) || (D1 < 0 && D2 > 0) || (D0 > 0 && D1 < 0) || (D0 < 0 && D1 > 0)) {
					freq = (8000/scount)*2; // 8000 samples/sec, scount/8000=T/2
					if(freq != freq0) {
						try {
							bwf.write(freq+"");
							bwf.newLine();
						} catch (IOException e) {
							e.printStackTrace();
							System.exit(1);
						}
						freq0 = freq;
					}
					scount = 0;
				}
			}
		}
		return decoded;
	}
	
	
	
	
	
	/*
	 * Method that sends requests and waits for image responses
	 */
	private static void GetImage(DatagramSocket send, DatagramPacket p, DatagramSocket receive)
			throws IOException {
		byte[] rxBuffer = new byte[2048]; //packet size up to 2 KB
		DatagramPacket q = new DatagramPacket(rxBuffer, rxBuffer.length);

		System.out.println("About to receive a shitload of bytes");
		ArrayList<Byte> image = new ArrayList<Byte>(); //image size up to 800 KB
		int packetlength = 0;
		int timeouts = 0;
		
		send.send(p);
		while(true){
			try {
				receive.receive(q);
				byte [] temp = rxBuffer;
				int L = q.getLength();
				if (packetlength == 0){
					packetlength = L; //first packet received
				}else if (packetlength != L){
					break; //first packet different from all other packets is the last packet
				}
				//add received bytes to image
				for (int i = 0; i < L; i++){
					image.add(temp[i]);
				}

			} catch (IOException e) {
				System.out.println(e);
				timeouts++;
				if (timeouts >= 10){
					//connection probably died or image ended and we didn't catch it
					break;
				}
			}
		}
		byte[] temp = new byte[image.size()];
		for (int i = 0; i < temp.length; i++){
			temp[i] = (byte) image.get(i);
		}
		
		
		String filename = "Image";
		filename = filename + System.currentTimeMillis();
		BufferedImage img = ImageIO.read(new ByteArrayInputStream(temp));
		File save = new File(filename);
		save.createNewFile();
		ImageIO.write(img, "jpg", save);
		System.out.println("Received a shitload of bytes with great success");
		
	}

	/*
	 * Method that sends requests and waits for string responses
	 */
	public static void GetStrings(DatagramSocket send, DatagramPacket p, DatagramSocket receive) throws IOException{
				
		byte[] rxBuffer = new byte[2048]; //up to 2KB
		DatagramPacket q = new DatagramPacket(rxBuffer, rxBuffer.length); 

		ArrayList<Long> responseTimes = new ArrayList<Long>();
		Long teststart = System.currentTimeMillis();
		while(true){
			Long tstart = System.currentTimeMillis();
			send.send(p);
			while(true){
				try{
					receive.receive(q);
					String message = new String(rxBuffer, 0, q.getLength());
					Long tstop = System.currentTimeMillis() - tstart;
					System.out.println(message);
					responseTimes.add(tstop);
					break;
				} catch (Exception e) {
					System.out.println(e);
				}
			}
			Long teststop = System.currentTimeMillis();
			if (teststop - teststart > 1000){ //test conducted for 4 minutes :)
				break;
			}
		}
		System.out.println("=========== End Of Transmission ===========");
		System.out.println("Packets Received:\n p="+responseTimes.toString());
		System.out.println("Number of Packets: "+responseTimes.size());
		
	}
}