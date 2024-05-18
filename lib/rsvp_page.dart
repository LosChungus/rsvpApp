import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RsvpPage extends StatefulWidget {
  @override
  _RsvpPageState createState() => _RsvpPageState();
}

class _RsvpPageState extends State<RsvpPage> {
  final TextEditingController _nameController = TextEditingController();
  final CollectionReference _rsvps = FirebaseFirestore.instance.collection('rsvps');

  Future<void> _addRsvp() async {
    if (_nameController.text.isEmpty) return;

    await _rsvps.add({
      'name': _nameController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _nameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RSVP for Event'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Your Name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addRsvp,
              child: Text('Submit RSVP'),
            ),
            Expanded(
              child: StreamBuilder(
                stream: _rsvps.orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var documents = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      var document = documents[index];
                      return ListTile(
                        title: Text(document['name']),
                        subtitle: Text(document['timestamp']?.toDate()?.toString() ?? 'Loading...'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
