import 'package:fluent_ui/fluent_ui.dart';
import 'package:hakata_file_manager/common/style.dart';
import 'package:hakata_file_manager/providers/home.dart';

class SearchCriteriaHeader extends StatelessWidget {
  final HomeProvider homeProvider;

  const SearchCriteriaHeader({
    required this.homeProvider,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: whiteColor,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text(
            '現在の絞り込み条件:',
            style: TextStyle(color: greyColor),
          ),
          const SizedBox(width: 4),
          Text(
              '登録日: ${homeProvider.searchCreateDateStart} ～ ${homeProvider.searchCreateDateEnd}, 取引先番号: ${homeProvider.searchClientNumber}'),
        ],
      ),
    );
  }
}
