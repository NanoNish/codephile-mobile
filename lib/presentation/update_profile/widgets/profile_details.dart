import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../data/constants/assets.dart';
import '../../../data/constants/colors.dart';
// import '../../../data/constants/styles.dart';
import '../../components/inputs/text_input.dart';
import '../bloc/update_profile_bloc.dart';

class ProfileDetails extends StatelessWidget {
  const ProfileDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.r),
          child: _profilePicture(),
        ),
        BlocBuilder<UpdateProfileBloc, UpdateProfileState>(
          builder: (context, state) {
            return TextInput(
              controller: UpdateProfileBloc.controllers['name'],
              hint: 'Name',
              errorText: state.errors['name'],
            );
          },
        ),
        SizedBox(height: 16.r),
        BlocBuilder<UpdateProfileBloc, UpdateProfileState>(
          builder: (context, state) {
            return TextInput(
              controller: UpdateProfileBloc.controllers['username'],
              hint: 'Username',
              errorText: state.errors['username'],
            );
          },
        ),
        SizedBox(height: 16.r),
        BlocBuilder<UpdateProfileBloc, UpdateProfileState>(
          buildWhen: (previous, current) =>
              previous.user?.institute != current.user?.institute,
          builder: (context, state) {
            return DropdownSearch<String>(
              selectedItem: state.user?.institute,
              items: UpdateProfileBloc.institutes,
              popupProps: const PopupProps.menu(showSearchBox: true),
              onChanged: (String? institute) {
                if (institute == null) return;

                context
                    .read<UpdateProfileBloc>()
                    .add(UpdateInstitute(institute: institute));
              },
            );
          },
        ),
        // TODO(aman-singh7): Blocked From backend. Information Needed
        // Align(
        //   alignment: Alignment.bottomRight,
        //   child: TextButton(
        //     onPressed: () {
        //       context.read<UpdateProfileBloc>().add(const SwitchView());
        //     },
        //     child: Text(
        //       'Change Password',
        //       style: AppStyles.h6.copyWith(color: AppColors.primary),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _profilePicture() {
    return BlocBuilder<UpdateProfileBloc, UpdateProfileState>(
      builder: (context, state) {
        final showDefault =
            state.image == null && (state.user?.picture ?? '').isEmpty;
        return GestureDetector(
          onTap: () =>
              context.read<UpdateProfileBloc>().add(const SelectImage()),
          child: Center(
            child: Stack(
              children: <Widget>[
                if (showDefault)
                  Container(
                    width: 180.r,
                    height: 180.r,
                    padding: EdgeInsets.all(40.r),
                    decoration: BoxDecoration(
                      color: AppColors.grey1.withOpacity(0.06),
                      border: Border.all(color: AppColors.grey1),
                      borderRadius: BorderRadius.circular(90.r),
                    ),
                    child: SvgPicture.asset(
                      AppAssets.defaultUserIcon,
                      fit: BoxFit.fill,
                    ),
                  )
                else
                  Container(
                    width: 180.r,
                    height: 180.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.fitWidth,
                        image: state.image != null
                            ? FileImage(state.image!)
                            : NetworkImage(state.user!.picture!)
                                as ImageProvider,
                      ),
                    ),
                  ),
                Positioned(
                  right: 0,
                  bottom: 16.r,
                  child: Container(
                    width: 45.r,
                    height: 45.r,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    child: Icon(
                      showDefault ? Icons.add_rounded : Icons.edit_rounded,
                      size: 24.r,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
