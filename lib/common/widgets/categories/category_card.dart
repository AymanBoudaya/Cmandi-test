import 'package:caferesto/features/shop/models/category_model.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants/sizes.dart';
import '../images/circular_image.dart';
import '../products/product_cards/widgets/rounded_container.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.showBorder,
    this.onTap,
    required this.category,
  });

  final CategoryModel category;
  final bool showBorder;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TRoundedContainer(
        padding: const EdgeInsets.all(AppSizes.sm),
        showBorder: showBorder,
        backgroundColor: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Icone
            CircularImage(
              isNetworkImage: true,
              image: category.image,
              backgroundColor: Colors.transparent,
              width: 50,
              height: 50,
              padding: 2,
            ),
            const SizedBox(width: AppSizes.spaceBtwItems / 2),

            /// Texte
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SizedBox(
                        width: constraints.maxWidth,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                category.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            if (category.isFeatured)
                              const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  // Badge "Populaire" si c'est une catégorie populaire
                  if (category.isFeatured)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Populaire',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Colors.amber.shade900,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

