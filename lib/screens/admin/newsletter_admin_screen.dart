import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../services/newsletter_service.dart';
import '../../services/auth_service.dart';
import '../../models/newsletter.dart';

class NewsletterAdminScreen extends StatefulWidget {
  const NewsletterAdminScreen({super.key});

  @override
  State<NewsletterAdminScreen> createState() => _NewsletterAdminScreenState();
}

class _NewsletterAdminScreenState extends State<NewsletterAdminScreen> {
  final NewsletterService _newsletterService = NewsletterService();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _tagsController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  int _subscriberCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSubscriberCount();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _loadSubscriberCount() async {
    final count = await _newsletterService.getSubscriberCount();
    setState(() => _subscriberCount = count);
  }

  Future<void> _createNewsletter() async {
    if (_titleController.text.trim().isEmpty || _bodyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in title and body'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final newsletterId = await _newsletterService.createNewsletter(
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      publishDate: _selectedDate,
      tags: tags,
    );

    setState(() => _isLoading = false);

    if (newsletterId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Newsletter created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _clearForm();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create newsletter'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _generateDigest() async {
    setState(() => _isLoading = true);

    final digest = await _newsletterService.generateRecommendationDigest();

    setState(() => _isLoading = false);

    if (digest != null) {
      _bodyController.text = digest;
      _titleController.text = 'Weekly Recommendations Digest - ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
      _tagsController.text = 'digest, recommendations, weekly';
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digest generated! Review and publish.'),
          backgroundColor: Colors.blue,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No recent recommendations to generate digest'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _clearForm() {
    _titleController.clear();
    _bodyController.clear();
    _tagsController.clear();
    setState(() => _selectedDate = DateTime.now());
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authService = Provider.of<AuthService>(context);

    if (!authService.isAdmin) {
      return const Scaffold(
        body: Center(
          child: Text('Access Denied: Admin Only'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Newsletter Admin',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Subscriber Stats'),
                  content: Text('Total Active Subscribers: $_subscriberCount'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Subscriber Count',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 32,
                      color: Colors.blue[600],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Subscribers',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        Text(
                          '$_subscriberCount',
                          style: GoogleFonts.roboto(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _generateDigest,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Generate Digest'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[600],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Create Newsletter Form
            Text(
              'Create Newsletter',
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Title Field
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Newsletter Title',
                hintText: 'Enter newsletter title...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.title),
              ),
              maxLength: 100,
            ),

            const SizedBox(height: 16),

            // Body Field
            TextField(
              controller: _bodyController,
              decoration: InputDecoration(
                labelText: 'Newsletter Body',
                hintText: 'Write your newsletter content here...\n\nSupports Markdown formatting:\n- **bold text**\n- *italic text*\n- # Headings\n- [Links](url)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.article),
                alignLabelWithHint: true,
              ),
              maxLines: 15,
              minLines: 8,
            ),

            const SizedBox(height: 16),

            // Tags and Date Row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _tagsController,
                    decoration: InputDecoration(
                      labelText: 'Tags (comma separated)',
                      hintText: 'stocks, market, analysis',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.tag),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: GoogleFonts.roboto(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _clearForm,
                    child: const Text('Clear Form'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createNewsletter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text('Publish Newsletter'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Recent Newsletters
            Text(
              'Recent Newsletters',
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            StreamBuilder<List<Newsletter>>(
              stream: _newsletterService.getAllNewslettersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final newsletters = snapshot.data ?? [];

                if (newsletters.isEmpty) {
                  return const Center(
                    child: Text('No newsletters created yet'),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: newsletters.length,
                  itemBuilder: (context, index) {
                    final newsletter = newsletters[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          newsletter.title,
                          style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Published: ${newsletter.publishDate.day}/${newsletter.publishDate.month}/${newsletter.publishDate.year}',
                          style: GoogleFonts.roboto(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (newsletter.isPublished)
                              const Icon(Icons.visibility, color: Colors.green)
                            else
                              const Icon(Icons.visibility_off, color: Colors.grey),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Newsletter'),
                                    content: const Text('Are you sure you want to delete this newsletter?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await _newsletterService.deleteNewsletter(newsletter.id);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
