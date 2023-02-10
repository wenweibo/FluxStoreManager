import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../store_settings_model.dart';

const kInitialLocation = CameraPosition(target: LatLng(0.0, 0.0));

class StoreSettingMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 15,
        right: 15,
        top: 15,
      ),
      child: Consumer<StoreSettingModel>(
        builder: (_, model, __) => Stack(
          children: [
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: (model.lat != null && model.long != null)
                    ? CameraPosition(target: LatLng(model.lat!, model.long!))
                    : kInitialLocation,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                onMapCreated: model.onMapCreated,
                markers: model.markers,
                compassEnabled: false,
                zoomControlsEnabled: false,
                onTap: model.isUpdating
                    ? (latLng) => model.updatePosition(latLng, isTapOnMap: true)
                    : null,
                gestureRecognizers: const <
                    Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                    EagerGestureRecognizer.new,
                  ),
                },
                onCameraMove: model.isUpdating ? model.onCameraMove : null,
              ),
            ),
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 15, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorLight,
                    borderRadius: BorderRadius.circular(9.0),
                  ),
                  child: TextField(
                    controller: model.searchAddressController,
                    onChanged: (val) => model.getPlaces(),
                    style: TextStyle(
                      color: model.isUpdating
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.grey,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    onTap: () => model.getLocationFromPlace(0),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 0.5,
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.2),
                          ),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10),
                        fillColor: Theme.of(context).primaryColorLight,
                        filled: true,
                        suffixIcon: model.state == StoreSettingState.searching
                            ? const CupertinoActivityIndicator()
                            : null),
                    maxLines: 1,
                    enabled: model.isUpdating,
                  ),
                ),
                if (model.autocompletePlaces.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColorLight,
                      borderRadius: BorderRadius.circular(9.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: List.generate(
                        model.autocompletePlaces.length,
                        (index) => InkWell(
                          onTap: () => model.getLocationFromPlace(index),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              bottom: 5.0,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on_rounded),
                                const SizedBox(height: 5),
                                Expanded(
                                  child: Text(
                                    model
                                        .autocompletePlaces[index].description!,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            /// Disable map
            if (!model.isUpdating)
              Container(
                color: Colors.transparent,
                height: 300,
              ),
          ],
        ),
      ),
    );
  }
}
