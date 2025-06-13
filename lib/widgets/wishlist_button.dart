import '/exports.dart';

class WishlistButton extends StatelessWidget {
  final ProductModel product;
  final double size;

  const WishlistButton({
    super.key,
    required this.product,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final WishlistController wishlistController = Get.find<WishlistController>();

    return Obx(() {
      final isInWishlist = wishlistController.isInWishlist(product.id);

      return GestureDetector(
        onTap: () => wishlistController.toggleWishlist(product),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isInWishlist ? Colors.red[50] : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            isInWishlist ? Icons.favorite : Icons.favorite_border,
            color: isInWishlist ? Colors.red : Colors.grey,
            size: size,
          ),
        ),
      );
    });
  }
}
