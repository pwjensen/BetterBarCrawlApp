enum SortOption {
  distance(label: 'Distance'),
  rating(label: 'Rating'),
  name(label: 'Name'),
  reviewCount(label: 'Most Reviewed');

  final String label;
  const SortOption({required this.label});
}
