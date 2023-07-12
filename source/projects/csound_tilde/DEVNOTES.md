# Fixing csound_tilde


- [ ] pattern of `using namespace std` 

	```c++
	./PatchScripter.h
	34:using namespace std;

	./eksepshun.h
	27:using namespace std;

	./sequencer.h
	41:using namespace std;

	./csound~.h
	30:using namespace std;

	./Args.h
	28:using namespace std;

	./PatchScripter.cpp
	28:using namespace std;

	./channel.cpp
	26:using namespace std;

	./Args.cpp
	30:using namespace std;

	./util.cpp
	30:using namespace std;

	./channel.h
	34:using namespace std;
	```

- [x] ambiguity between `std::byte` (added in c++ 17) and `typedef byte` in `definitions.h`
	```c++
	definitions.h
	44:	typedef unsigned char byte;
	49:		// Sequencer uses boost.serialization which requires 1-byte bool (darwin ppc arch uses 4-byte bool).
	52:	typedef unsigned char byte;

	CsoundObject.cpp
	582:// Read at most 'nbytes' bytes from our MidiBuffer and store in 'buf'. Returns the
	583:// actual number of bytes read. Incomplete messages (such as a note on status without
	584:// the data bytes) should not be returned.
	585:int midiReadCallback(CSOUND *csound, void *userData, unsigned char *buf, int nbytes)
	590:	int bytesLeft = nbytes, bytesRead = 0, msg_size = 0;
	592:	while(bytesLeft)
	595:		msg_size = mb->DequeueCompleteMessage(&buf[bytesRead], bytesLeft);
	599:			if(seq->Recording()) seq->AddMIDIEvent(&buf[bytesRead], msg_size, true);
	600:			if(0xB0 == (buf[bytesRead] & 0xf0))
	603:				byte b = 0, chan, ctrl, val;
	605:				ctrl = buf[bytesRead + 1];
	606:				val = buf[bytesRead + 2];
	609:			bytesRead += msg_size;
	610:			bytesLeft -= msg_size;
	613:	return bytesRead;
	620:int midiWriteCallback(CSOUND *csound, void *userData, const unsigned char *buf, int nbytes)
	623:	int bytesWritten = 0;
	625:	while(bytesWritten < nbytes) outlet_int(x->midi_outlet, (int)buf[bytesWritten++]);
	627:	return bytesWritten;

	sequencer.h
	118:	MidiEvent(int time, const byte *buf, int bytes);
	128:	byte m_buffer[MAX_MIDI_MESSAGE_SIZE];
	170:	bool AddMIDIEvent(byte *buf, int nBytes, bool lock); // Returns true on success.
	185:	inline void UpdateCtrlMatrix(byte chan, byte ctrl, byte val) { m_ctrlMatrix[chan][ctrl] = val; }
	237:	byte m_ctrlMatrix[16][128];
	238:	byte m_activeNoteMatrix[16][128];

	memory.h
	46:// Write len bytes from src to buffer at count offset.  If needed, grow buffer and
	48:int BufferWrite(byte **buffer, const void *src, int len, int *count, int *bufferSize);

	util.h
	36:// Reverses size bytes in src.
	37:void reverseBytes(byte *b, int size);
	39:void reverseNumber(byte *b, int size, bool reverse);

	csound~.cpp
	406:	x->cso->m_midiBuffer.Enqueue((byte) n);
	471:	byte buffer[MAX_MIDI_MESSAGE_SIZE];
	480:			buffer[i] = (byte) atom_getlong(&argv[i]);

	midi.h
	37:// A circular byte buffer.
	53:	int DequeueCompleteMessage(byte* buf, int n);
	57:	/* When m_sysex == true, any data bytes recieved through this function */
	62:	void Enqueue(byte b, bool lock = true);
	64:	/* Enqueue n bytes from b into m_buffer.  b should contain only 1 complete MIDI message. */
	66:	void EnqueueBuffer(byte* b, int n, bool lock = true);
	76:	/* Dequeue n bytes into b from mb->buffer. */
	78:	void DequeueBuffer(byte* b, int n);
	80:	/* Dequeue a single byte from the buffer. */
	82:	byte Dequeue();
	84:	boost::circular_buffer<byte> m_buffer; // Contains the MIDI bytes.
	88:	byte m_activeNoteMatrix[16][128];

	midi.cpp
	41:byte MidiBuffer::Dequeue()
	43:	byte b = m_buffer.front();
	48:void MidiBuffer::DequeueBuffer(byte* b, int n)
	57:int MidiBuffer::DequeueCompleteMessage(byte* buf, int n)
	59:	byte b, status;
	64:		b = m_buffer.front(); // Peek into buffer to get next status byte (don't dequeue).
	68:		case 0x80: // Note-off (3 bytes)
	76:		case 0x90: // Note-on (3 bytes)
	84:		case 0xA0: // Aftertouch (3 bytes)
	85:		case 0xE0: // Pitch Bend (3 bytes)
	86:		case 0xB0: // Control Change (3 bytes)
	93:		case 0xC0: // Program Change (2 bytes)
	94:		case 0xD0: // Channel Aftertouch (2 bytes)
	102:			Dequeue(); // Discard the current byte.
	109:void MidiBuffer::Enqueue(byte b, bool lock)
	122:void MidiBuffer::EnqueueBuffer(byte* b, int n, bool lock)
	124:	byte status = 0;
	129:	case 0x80: // Note-off (3 bytes)
	130:	case 0x90: // Note-on (3 bytes)
	131:	case 0xA0: // Aftertouch (3 bytes)
	132:	case 0xB0: // Control Change (3 bytes)
	133:	case 0xE0: // Pitch Bend (3 bytes)
	136:	case 0xC0: // Program Change (2 bytes)
	137:	case 0xD0: // Channel Aftertouch (2 bytes)
	146:	// If there isn't enough space for all bytes stored in b, then don't enqueue anything.
	156:	byte buf[3];
	161:	for(byte c=0; c<16; c++)
	162:		for(byte p=0; p<128; p++)

	sequencer.cpp
	74:MidiEvent::MidiEvent(int time, const byte *buf, int bytes) :
	75:	Event(EVENT_TYPE_MIDI, time), m_size(bytes)
	85:	string byte_str;
	87:	byte_str = pt.get<string>("bytes");
	88:	Parser::parse_integers(byte_str.begin(), byte_str.end(), v);
	100:	string byte_str;
	103:	back_insert_iterator<string> sink(byte_str);
	105:	t.put("bytes", byte_str);
	147:			m_ctrlMatrix[i][j] = (byte) 128;
	255:	byte ch, ctrl;
	256:	byte buf[3];
	314:	byte activeNoteMatrix[16][128];
	315:	byte status = 0, chan, pitch, vel, b[3];
	375:				b[0] = (byte)i | 0x80;
	376:				b[1] = (byte)j;
	405:	byte b[3];
	419:				b[0] = (byte)i | 0x80;
	420:				b[1] = (byte)j;
	475:bool Sequencer::AddMIDIEvent(byte *buf, int nBytes, bool lock)
	490:	byte status, chan, pitch, vel;
	666:	byte *buffer = NULL, *bytePtr = NULL;
	675:	reverseBytes((byte*)&magic_number_reverse, sizeof(int));
	696:	buffer = (byte*) MemoryNew(fileSize);
	716:	bytePtr = buffer;
	717:	magic = *(int*)bytePtr;
	718:	bytePtr += sizeof(int);
	727:		numEvents = *(int*)bytePtr;
	728:		reverseNumber((byte*)&numEvents, sizeof(int), reverse);
	729:		bytePtr += sizeof(int);
	733:			type = *(int*)bytePtr;
	734:			reverseNumber((byte*)&type, sizeof(int), reverse);
	735:			bytePtr += sizeof(int);
	737:			time = *(int*)bytePtr;
	738:			reverseNumber((byte*)&time, sizeof(int), reverse);
	739:			bytePtr += sizeof(int);
	741:			len = *(int*)bytePtr; // data1 size
	742:			reverseNumber((byte*)&len, sizeof(int), reverse);
	743:			bytePtr += sizeof(int);
	750:				memcpy(buf, bytePtr, len);		// get data1
	751:				bytePtr += len + sizeof(int);	// skip data1 and data2 size (== 0 in this case)
	755:				memcpy(buf, bytePtr, len);		// get data1
	756:				bytePtr += len + sizeof(int);	// skip data1 and data2 size (== sizeof(float) in this case)
	757:				value = *(float*)bytePtr;		// get data2
	758:				reverseNumber((byte*)&value, sizeof(int), reverse);
	759:				bytePtr += sizeof(float);		// skip data2
	763:				memcpy(buf, bytePtr, len);		// get data1
	764:				bytePtr += len;					// skip data1
	765:				data2_size = *(int*)bytePtr;	// get data2 size
	766:				bytePtr += sizeof(int);			// skip data2 size
	767:				AddStringEvent(buf, (char*)bytePtr, false); // Add data2 string to sequencer.
	768:				bytePtr += data2_size;			// skip data2
	771:				memcpy(buf, bytePtr, len);		// data1
	772:				bytePtr += len + sizeof(int);	// skip data1 and data2 size (== 0 in this case)
	773:				AddMIDIEvent((byte*) buf, len, false);
	787:	byte *buffer = NULL;
	788:	int realloc_result=0, result=0, len, byteCount = 0, bufferSize = DEFAULT_SAVE_LOAD_BUFFER_SIZE;
	807:	buffer = (byte *) MemoryNew(bufferSize);
	816:	realloc_result = BufferWrite(&buffer, &magic, sizeof(int), &byteCount, &bufferSize);
	822:		realloc_result = BufferWrite(&buffer, &numEvents, sizeof(int), &byteCount, &bufferSize);
	831:			realloc_result = BufferWrite(&buffer, &it->m_type, sizeof(int), &byteCount, &bufferSize);
	835:			realloc_result = BufferWrite(&buffer, &it->m_time, sizeof(int), &byteCount, &bufferSize);
	854:			realloc_result = BufferWrite(&buffer, &len, sizeof(int), &byteCount, &bufferSize);
	858:			realloc_result = BufferWrite(&buffer, vptr, len, &byteCount, &bufferSize);
	880:			realloc_result = BufferWrite(&buffer, &len, sizeof(int), &byteCount, &bufferSize);
	884:			realloc_result = BufferWrite(&buffer, vptr, len, &byteCount, &bufferSize);
	890:		result = fwrite(buffer, 1, byteCount, fp);
	894:	if(realloc_result == 1 || result != byteCount) object_post(m_obj, "fwrite() failed to write to %s.", file.c_str());

	util.cpp
	85:// Reverses size bytes in b.
	86:void reverseBytes(byte *b, int size)
	101:void reverseNumber(byte *b, int size, bool reverse)

	CsoundObject.h
	120:int midiReadCallback(CSOUND *csound, void *userData, unsigned char *buf, int nbytes);
	123:int midiWriteCallback(CSOUND *csound, void *userData, const unsigned char *buf, int nbytes);

	memory.cpp
	26:int BufferWrite(byte **buffer, const void *src, int len, int *count, int *bufferSize)
	34:		*buffer = (byte*) realloc(*buffer, *bufferSize);
	48:	// Update the byte count (i.e. buffer offset).
	```


- [x] use of `auto_ptr` which was removed in c++17 in `csound~.cpp`

	```c++
	csound~.cpp
	629:		std::auto_ptr<CsoundObject> auto_p(x->cso);  // Just in case exception happens before end of try.
	```
